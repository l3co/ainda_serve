# Python Testing Strategy

## Philosophy

Test observable behavior — what a function or module does from the outside — not how it does it. A test that breaks when you rename a private helper is testing the wrong thing. A test that breaks when the public contract changes is doing its job.

## Framework Baseline

- **pytest** for all new tests.
- **pytest-mock** or `unittest.mock` for test doubles.
- **hypothesis** for property-based testing when appropriate and already in the project.
- **pytest-asyncio** for async code.
- Do not introduce new testing frameworks without justification.

## Test Organization

```
myservice/
├── orders/
│   ├── service.py
│   └── repository.py
└── tests/
    ├── orders/
    │   ├── test_service.py
    │   └── test_repository.py
    └── conftest.py          # shared fixtures
```

Alternatively, co-locate tests within the package:

```
myservice/
└── orders/
    ├── service.py
    ├── repository.py
    └── tests/
        ├── test_service.py
        └── test_repository.py
```

Use whichever style is already established in the project.

## Unit Tests

Unit tests verify a single function or class in isolation:

```python
def test_calculate_total_with_standard_discount() -> None:
    items = [OrderItem(name="book", price_in_cents=1000, quantity=2)]
    total = calculate_total(items, discount_rate=0.10)
    assert total == 1800  # 2000 * 0.90


def test_calculate_total_raises_when_items_empty() -> None:
    with pytest.raises(ValueError, match="items"):
        calculate_total([], discount_rate=0.0)
```

- Replace external I/O with test doubles: never hit the real database or network in a unit test.
- Use `pytest.raises` to verify exception behavior.
- Keep each test function focused on one scenario.

## Fixtures

Use pytest fixtures for reusable test setup:

```python
@pytest.fixture
def order_repository() -> OrderRepository:
    return FakeOrderRepository()


@pytest.fixture
def order_service(order_repository: OrderRepository) -> OrderService:
    return OrderService(repository=order_repository)


def test_service_creates_order_with_correct_total(order_service: OrderService) -> None:
    items = [OrderItem(name="pen", price_in_cents=200, quantity=3)]
    order = order_service.create_order(items)
    assert order.total_in_cents == 600
```

Prefer fixtures over `setUp`/`tearDown` — they are more composable and explicit.

Use `scope="session"` for expensive fixtures that are safe to share (e.g., a database container). Default to `scope="function"`.

## Integration Tests

Integration tests verify real collaborations with external systems:

```python
@pytest.mark.integration
def test_repository_finds_order_by_customer_id(db_session: Session) -> None:
    repo = SqlOrderRepository(db_session)
    order = Order(customer_id="cust-1", items=[])
    repo.save(order)

    result = repo.find_by_customer_id("cust-1")

    assert len(result) == 1
    assert result[0].customer_id == "cust-1"
```

Mark integration tests with a marker (`@pytest.mark.integration`) and run them separately from unit tests:

```sh
pytest -m "not integration"   # unit tests only
pytest -m integration         # integration tests only
```

Use a test database, Docker container, or in-memory SQLite for integration tests — never the production database.

## Test Doubles

| Double type | When to use |
|---|---|
| Fake | In-memory implementation of a repository or service — preferred for complex collaborators |
| Mock | Verify that specific calls were made with specific arguments |
| Stub | Return fixed values from a function or method without verifying calls |
| Patch | Replace a module-level function or attribute during a test |

```python
# Fake repository:
class FakeOrderRepository:
    def __init__(self) -> None:
        self._orders: dict[str, Order] = {}

    def save(self, order: Order) -> None:
        self._orders[order.id] = order

    def find_by_id(self, order_id: str) -> Order | None:
        return self._orders.get(order_id)
```

Prefer fakes for repositories and simple collaborators. Use `unittest.mock.patch` sparingly — primarily for external I/O or time-dependent code.

Avoid patching the internal implementation of code you own — patch at the boundary.

## Parameterized Tests

Use `pytest.mark.parametrize` for data-driven cases:

```python
@pytest.mark.parametrize(
    "subtotal, rate, expected",
    [
        (1000, 0.0, 1000),
        (1000, 0.10, 1100),
        (0, 0.10, 0),
    ],
    ids=["no tax", "ten percent tax", "zero subtotal"],
)
def test_applies_tax(subtotal: int, rate: float, expected: int) -> None:
    assert apply_tax(subtotal, rate) == expected
```

## Async Tests

```python
@pytest.mark.asyncio
async def test_async_service_returns_result() -> None:
    service = AsyncOrderService(repository=FakeAsyncRepository())
    result = await service.get_order("order-1")
    assert result is not None
```

## Naming

Test function names must be in English and describe the scenario:

```python
def test_create_order_with_valid_items_returns_order() -> None: ...
def test_create_order_raises_when_items_is_empty() -> None: ...
def test_find_by_id_returns_none_when_not_found() -> None: ...
```

## What to Test

Prioritize:

- Business logic and domain rules
- Error paths and exception messages
- Boundary conditions: empty collections, None values, maximum values
- Critical data transformations
- Regressions — every bug fix should add a test

Do not test:

- Private functions with no observable external effect
- Framework behavior (Django ORM, SQLAlchemy internals)
- Generated code or migrations
- Trivial property accessors with no logic

## Coverage

Use coverage as a diagnostic tool, not a target:

```sh
pytest --cov=myservice --cov-report=html
```

Focus effort on modules containing domain logic. A well-tested service layer with 75% coverage is more valuable than 95% coverage achieved by testing trivial accessors.

## conftest.py Hierarchy

`conftest.py` files are loaded by pytest automatically. They can exist at multiple levels in the project tree. Higher-level fixtures are available to all tests below them.

```
myservice/
├── conftest.py              # root: session-scoped fixtures (DB connection, app client)
├── tests/
│   ├── conftest.py          # test root: shared fixtures for all test modules
│   ├── orders/
│   │   ├── conftest.py      # order-specific fixtures (fake order repository)
│   │   ├── test_service.py
│   │   └── test_repository.py
│   └── customers/
│       ├── conftest.py      # customer-specific fixtures
│       └── test_service.py
```

Each `conftest.py` at a deeper level can override or extend fixtures from the parent:

```python
# tests/conftest.py — shared across all tests:
@pytest.fixture(scope="session")
def database_url() -> str:
    return os.environ.get("TEST_DATABASE_URL", "sqlite:///test.db")


@pytest.fixture(scope="session")
def db_engine(database_url: str):
    engine = create_engine(database_url)
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)


# tests/orders/conftest.py — order-specific:
@pytest.fixture
def fake_order_repository() -> FakeOrderRepository:
    return FakeOrderRepository()

@pytest.fixture
def order_service(fake_order_repository: FakeOrderRepository) -> OrderService:
    return OrderService(repository=fake_order_repository)
```

Guidelines:
- Use `scope="session"` for expensive, read-only setup (database containers, HTTP clients).
- Use `scope="function"` (default) for anything that modifies shared state.
- Keep `conftest.py` files focused — do not dump all fixtures into the root `conftest.py`.
- Name fixtures clearly; they are the test's documentation of its dependencies.

## pytest Markers

Register custom markers in `pyproject.toml` to avoid warnings and enable filtering:

```toml
[tool.pytest.ini_options]
markers = [
    "integration: requires a live database or external service",
    "slow: takes more than 1 second to run",
    "unit: pure unit tests with no I/O",
]
```

Use in tests:

```python
@pytest.mark.integration
def test_repository_persists_order(db_session: Session) -> None: ...

@pytest.mark.slow
def test_bulk_import_performance() -> None: ...
```

Run selectively:

```sh
pytest -m "not integration"       # fast tests only
pytest -m "integration"           # integration tests only
pytest -m "unit and not slow"     # unit tests excluding slow ones
```

## Running Tests

```sh
pytest                            # all tests
pytest tests/orders/              # specific directory
pytest -k "discount"              # tests matching a keyword
pytest -m "not integration"       # exclude integration tests
pytest --cov=myservice            # with coverage
pytest -x                         # stop at first failure
pytest -v                         # verbose output with test names
pytest --tb=short                 # shorter tracebacks
```
