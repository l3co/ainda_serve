# Python Conventions

## Naming

- **Modules and packages**: `snake_case` — `order_service`, `user_repository`, `config`
- **Functions and methods**: `snake_case` — `calculate_total`, `find_by_email`, `send_notification`
- **Classes**: `PascalCase` — `OrderService`, `UserRepository`, `PaymentGateway`
- **Constants**: `UPPER_SNAKE_CASE` — `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_SECONDS`
- **Private functions and attributes**: leading underscore — `_validate_email`, `_connection`
- **Type variables**: single uppercase letters or `PascalCase` — `T`, `UserT`
- All identifiers must be in English.
- Avoid generic names: `data`, `info`, `item`, `object`, `manager`, `helper`, `utils`, `processor`.
- Test functions: `test_<what>_<when>_<expected>` — `test_calculate_total_with_empty_items_returns_zero`

## File Organization

- One primary concern per module.
- Related dataclasses, models, or domain types in their own module (e.g., `models.py` or `domain.py`).
- Keep `__init__.py` minimal — avoid importing everything into the package namespace by default.
- Do not use wildcard imports: `from module import *`.

## Type Hints

- Add type hints to all function signatures in new or modified code.
- Use `from __future__ import annotations` in Python 3.9 and earlier for forward references.
- Use `Optional[T]` or `T | None` (Python 3.10+) for values that may be absent.
- Use `list[T]`, `dict[K, V]`, `tuple[T, ...]` (Python 3.9+) instead of `List`, `Dict`, `Tuple` from `typing`.
- Use `TypeAlias` (Python 3.10+) or comment aliases for complex type aliases.
- Use `Protocol` to define structural interfaces — preferred over ABCs for duck-typed behaviors.
- Use `TypeVar` for generic functions that need to express type relationships.
- Run `mypy --strict` or `pyright` if configured — treat type errors as real issues.

## Dataclasses and Pydantic

- Use `@dataclass(frozen=True)` for immutable value objects.
- Use `@dataclass` for mutable domain objects with associated behavior.
- Use `TypedDict` for plain dictionary structures passed between functions.
- Use Pydantic `BaseModel` when the project already uses Pydantic (FastAPI, etc.).
- Do not mix dataclasses and Pydantic models for the same domain concept in the same module.

## Exception Handling

- Use specific exception types — not bare `except:` or `except Exception:`.
- Define custom exceptions as subclasses of the appropriate standard exception:
  ```python
  class OrderNotFoundError(ValueError):
      def __init__(self, order_id: str) -> None:
          super().__init__(f"order not found: {order_id}")
          self.order_id = order_id
  ```
- Catch exceptions at the level where you can do something meaningful about them.
- Never swallow exceptions silently — log, re-raise, or handle explicitly.
- Re-raise with `raise ... from err` to preserve the exception chain.
- Exception messages must be in English and be lowercase (consistent with Python stdlib convention).

## Imports

- Group imports: standard library, then third-party, then local. Separate groups with blank lines.
- Use absolute imports — not relative imports at the top level.
- Use relative imports within a package when it aids clarity.
- Never use `from module import *`.
- Sort imports with `isort` or `ruff` — use whatever is configured in the project.

## Mutability and Immutability

- Prefer immutable default values — never use mutable defaults in function signatures:
  ```python
  # Incorrect — the list is shared across all calls:
  def add_item(items: list[str] = []) -> list[str]: ...
  
  # Correct:
  def add_item(items: list[str] | None = None) -> list[str]:
      if items is None:
          items = []
      ...
  ```
- Use `tuple` instead of `list` when the collection is not meant to be modified.
- Use `frozenset` instead of `set` for immutable sets.

## Comprehensions and Generators

- Use list comprehensions for simple transformations: `[x * 2 for x in items]`
- Use generator expressions for lazy evaluation: `sum(x * 2 for x in items)`
- Avoid nested comprehensions deeper than two levels — extract into a function.
- Use `dict` and `set` comprehensions when they are clearer than a loop.

## Async

- Use `async def` for functions that perform I/O.
- Use `await` for all awaitable calls — do not call coroutines without awaiting them.
- Use async context managers (`async with`) for async resources.
- Use `asyncio.gather` or `asyncio.TaskGroup` (Python 3.11+) for concurrent tasks.
- Do not call blocking I/O functions (file reads, `requests.get`) inside `async def` — use `asyncio.to_thread` or async equivalents.

## Context Managers

- Use `with` for resource management: files, database connections, locks.
- Implement `__enter__` and `__exit__` (or `@contextmanager`) for custom resource types.
- Use `contextlib.suppress` only for expected, explicitly documented no-op exceptions.

## Dependencies

- Declare dependencies in `pyproject.toml` (preferred for new projects) or `requirements.txt`.
- Use a virtual environment — never install into the system Python.
- Pin exact versions for application deployments; use version ranges for libraries.
- Separate development dependencies from production dependencies.
- Before adding a dependency: does the standard library suffice? Is the package maintained? Is the license compatible?

## Observability

### Structured Logging

Prefer `structlog` when the project uses it; fall back to the standard `logging` module with JSON formatting otherwise.

```python
# With structlog:
import structlog

log = structlog.get_logger()

def create_order(command: CreateOrderCommand) -> Order:
    log.info("creating_order", customer_id=command.customer_id)
    order = Order(...)
    log.info("order_created", order_id=order.id, total_in_cents=order.total_in_cents)
    return order
```

```python
# With standard logging + context variable for request ID:
import logging
import contextvars

request_id_var: contextvars.ContextVar[str] = contextvars.ContextVar("request_id", default="-")

class RequestIdFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        record.request_id = request_id_var.get()
        return True
```

Rules:
- Use event names in `snake_case` for log events with `structlog` (e.g., `"order_created"`, not `"Order Created"`).
- Pass context as keyword arguments — not embedded in the message string.
- Never log passwords, tokens, credit card numbers, or PII — even at `DEBUG` level.
- Use `contextvars.ContextVar` to propagate request-scoped context (request ID, user ID) across async calls.
- Log at the correct level: `debug` for internal state, `info` for significant events, `warning` for recoverable issues, `error` for failures.

### Tracing

When using OpenTelemetry:

```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

def process_order(order_id: str) -> None:
    with tracer.start_as_current_span("process_order") as span:
        span.set_attribute("order.id", order_id)
        # ...
```

Instrument at the boundary (HTTP handlers, repository functions, external calls) — not pure domain logic.

## Patterns to Avoid

- Classes used only as namespaces (use a module instead)
- Mutable default arguments
- Bare `except:` blocks
- Catching `Exception` without re-raising or logging
- `from module import *`
- Import-time side effects (database connections, network calls at module load)
- Functions longer than a single level of abstraction without extraction
- Excessive use of `**kwargs` that hides the actual parameters
- Metaprogramming (decorators that change behavior invisibly, dynamic `__getattr__`) without clear justification
- Dynamic attribute creation (`obj.__dict__[key] = value`) without a documented reason
