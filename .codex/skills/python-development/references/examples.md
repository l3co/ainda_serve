# Python Idiomatic Examples

Short, focused examples. Not a complete application — reference patterns only.

---

## Function Over Class for Stateless Logic

```python
# Correct: a pure function is simpler and testable without instantiation.
def calculate_discount(subtotal: int, rate: float) -> int:
    if rate < 0 or rate > 1:
        raise ValueError(f"discount rate must be between 0 and 1, got {rate}")
    return int(subtotal * (1 - rate))
```

---

## Value Object with Dataclass

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Money:
    amount_in_cents: int
    currency: str

    def __post_init__(self) -> None:
        if self.amount_in_cents < 0:
            raise ValueError(f"amount must be non-negative, got {self.amount_in_cents}")
        if not self.currency:
            raise ValueError("currency must not be empty")

    def add(self, other: "Money") -> "Money":
        if self.currency != other.currency:
            raise ValueError(f"cannot add {self.currency} and {other.currency}")
        return Money(self.amount_in_cents + other.amount_in_cents, self.currency)
```

---

## Protocol for Structural Interfaces

```python
from typing import Protocol


class NotificationSender(Protocol):
    def send(self, recipient: str, message: str) -> None: ...


# Any class with a compatible `send` method satisfies this Protocol
# without inheritance — no coupling to an ABC.
class EmailSender:
    def send(self, recipient: str, message: str) -> None:
        # send email implementation
        ...


class SmsSender:
    def send(self, recipient: str, message: str) -> None:
        # send SMS implementation
        ...
```

---

## Exception Handling

```python
# Custom exception with context:
class OrderNotFoundError(ValueError):
    def __init__(self, order_id: str) -> None:
        super().__init__(f"order not found: {order_id}")
        self.order_id = order_id


# Service function — raises at the right level:
def get_order(order_id: str, repository: OrderRepository) -> Order:
    order = repository.find_by_id(order_id)
    if order is None:
        raise OrderNotFoundError(order_id)
    return order
```

---

## Type Hints with Optional

```python
from __future__ import annotations


def find_customer(email: str, repository: CustomerRepository) -> Customer | None:
    return repository.find_by_email(email)


# Caller handles the None case explicitly:
customer = find_customer("alice@example.com", repo)
if customer is None:
    raise CustomerNotFoundError("alice@example.com")
```

---

## Pytest Fixture and Test

```python
import pytest


@pytest.fixture
def fake_order_repository() -> FakeOrderRepository:
    return FakeOrderRepository()


@pytest.fixture
def order_service(fake_order_repository: FakeOrderRepository) -> OrderService:
    return OrderService(repository=fake_order_repository)


def test_create_order_returns_order_with_correct_total(
    order_service: OrderService,
) -> None:
    items = [OrderItem(name="book", price_in_cents=500, quantity=2)]
    order = order_service.create_order(items)
    assert order.total_in_cents == 1000


def test_create_order_raises_when_items_is_empty(order_service: OrderService) -> None:
    with pytest.raises(ValueError, match="items"):
        order_service.create_order([])
```

---

## Parameterized Test

```python
@pytest.mark.parametrize(
    "amount, rate, expected",
    [
        (1000, 0.0, 1000),
        (1000, 0.10, 900),
        (500, 0.50, 250),
    ],
    ids=["no discount", "ten percent", "fifty percent"],
)
def test_calculate_discount(amount: int, rate: float, expected: int) -> None:
    assert calculate_discount(amount, rate) == expected
```

---

## Mutable Default Argument — Anti-Pattern vs. Correct

```python
# Incorrect — the list is shared across all calls (Python anti-pattern):
def add_item(name: str, items: list[str] = []) -> list[str]:
    items.append(name)
    return items


# Correct:
def add_item(name: str, items: list[str] | None = None) -> list[str]:
    result = list(items) if items is not None else []
    result.append(name)
    return result
```

---

## Over-Engineering vs. Simplicity

### Overly complex (avoid)

```python
# ABC + Factory for a two-line calculation with one implementation.
from abc import ABC, abstractmethod

class DiscountStrategy(ABC):
    @abstractmethod
    def apply(self, subtotal: int) -> int: ...

class PercentageDiscountStrategy(DiscountStrategy):
    def __init__(self, rate: float) -> None:
        self.rate = rate
    def apply(self, subtotal: int) -> int:
        return int(subtotal * (1 - self.rate))

class DiscountStrategyFactory:
    @staticmethod
    def create(discount_type: str, rate: float) -> DiscountStrategy:
        if discount_type == "percentage":
            return PercentageDiscountStrategy(rate)
        raise ValueError(f"unknown discount type: {discount_type}")
```

### Simplified (prefer when only one discount type exists)

```python
def apply_percentage_discount(subtotal: int, rate: float) -> int:
    return int(subtotal * (1 - rate))
```

---

## Python-Specific Anti-Patterns

### Mutable Default Argument (Bug, Not Style)

```python
# Bug: the same list is reused across all calls.
def add_tag(tag: str, tags: list[str] = []) -> list[str]:
    tags.append(tag)
    return tags

add_tag("python")   # returns ["python"]
add_tag("rust")     # returns ["python", "rust"] — wrong!

# Correct:
def add_tag(tag: str, tags: list[str] | None = None) -> list[str]:
    result = list(tags) if tags is not None else []
    result.append(tag)
    return result
```

### Bare except Hides Bugs

```python
# Anti-pattern: catches KeyboardInterrupt, SystemExit, and real bugs.
try:
    process_order(order_id)
except:
    pass  # everything disappears

# Correct: be specific.
try:
    process_order(order_id)
except OrderNotFoundError:
    logger.warning("order not found: %s", order_id)
except Exception:
    logger.exception("unexpected error processing order %s", order_id)
    raise
```

### Class as Namespace

```python
# Anti-pattern: class with only static methods — just use a module.
class StringUtils:
    @staticmethod
    def to_slug(text: str) -> str:
        return text.lower().replace(" ", "-")

    @staticmethod
    def truncate(text: str, max_length: int) -> str:
        return text[:max_length]

# Correct: module-level functions.
# string_utils.py
def to_slug(text: str) -> str:
    return text.lower().replace(" ", "-")

def truncate(text: str, max_length: int) -> str:
    return text[:max_length]
```

### Import-Time Side Effect

```python
# Anti-pattern: database connection established when module is imported.
# db.py
engine = create_engine(os.environ["DATABASE_URL"])  # runs at import time

# Correct: lazy initialization or explicit setup.
# db.py
_engine: Engine | None = None

def get_engine() -> Engine:
    global _engine
    if _engine is None:
        _engine = create_engine(os.environ["DATABASE_URL"])
    return _engine
```

### Swallowed Exception with Generic Logging

```python
# Anti-pattern: logs but loses the exception type and stack trace.
try:
    save_order(order)
except Exception as e:
    logger.error(f"something went wrong: {e}")  # traceback is lost

# Correct: use exc_info=True or logger.exception().
try:
    save_order(order)
except Exception:
    logger.exception("failed to save order %s", order.id)
    raise  # or handle explicitly
```

---

## Async FastAPI Route

```python
from fastapi import APIRouter, Depends, HTTPException

router = APIRouter()


@router.get("/orders/{order_id}")
async def get_order_endpoint(
    order_id: str,
    service: OrderService = Depends(get_order_service),
) -> OrderResponse:
    try:
        order = await service.get_order(order_id)
    except OrderNotFoundError:
        raise HTTPException(status_code=404, detail=f"order not found: {order_id}")
    return OrderResponse.from_domain(order)
```
