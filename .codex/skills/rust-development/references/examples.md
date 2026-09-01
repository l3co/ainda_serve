# Rust Idiomatic Examples

Short, focused examples. Not a complete application — reference patterns only.

---

## Newtype for Domain Concepts

```rust
use uuid::Uuid;

// Newtype wraps a primitive — prevents mixing order IDs and user IDs.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct OrderId(Uuid);

impl OrderId {
    pub fn new() -> Self {
        Self(Uuid::new_v4())
    }

    pub fn as_str(&self) -> &str {
        // Returning a reference tied to self's lifetime — no allocation.
        // (In practice, format to a String; shown here for lifetime illustration)
        self.0.to_string().leak()  // Not recommended in real code; use Display instead
    }
}

impl std::fmt::Display for OrderId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}
```

---

## Value Object with Validation

```rust
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Money {
    amount_in_cents: i64,
    currency: Currency,
}

impl Money {
    pub fn new(amount_in_cents: i64, currency: Currency) -> Result<Self, MoneyError> {
        if amount_in_cents < 0 {
            return Err(MoneyError::NegativeAmount(amount_in_cents));
        }
        Ok(Self { amount_in_cents, currency })
    }

    pub fn add(&self, other: &Money) -> Result<Money, MoneyError> {
        if self.currency != other.currency {
            return Err(MoneyError::CurrencyMismatch {
                left: self.currency.clone(),
                right: other.currency.clone(),
            });
        }
        Money::new(self.amount_in_cents + other.amount_in_cents, self.currency.clone())
    }
}
```

---

## Error Type with thiserror

```rust
#[derive(Debug, thiserror::Error)]
pub enum OrderError {
    #[error("order not found: {0}")]
    NotFound(OrderId),

    #[error("order cannot transition from {from:?} to {to:?}")]
    InvalidTransition { from: OrderStatus, to: OrderStatus },

    #[error("repository error: {0}")]
    Repository(#[from] RepositoryError),
}
```

---

## Trait Near Consumer

```rust
// In the service module — defines what it needs, not what the repository provides.
#[async_trait::async_trait]
pub trait OrderRepository: Send + Sync {
    async fn find_by_id(&self, id: &OrderId) -> Result<Option<Order>, RepositoryError>;
    async fn save(&self, order: &Order) -> Result<(), RepositoryError>;
}

pub struct OrderService<R: OrderRepository> {
    repository: R,
}

impl<R: OrderRepository> OrderService<R> {
    pub fn new(repository: R) -> Self {
        Self { repository }
    }

    pub async fn cancel_order(&self, id: &OrderId) -> Result<Order, OrderError> {
        let mut order = self.repository.find_by_id(id)
            .await?
            .ok_or_else(|| OrderError::NotFound(id.clone()))?;

        order.cancel()?;

        self.repository.save(&order).await?;
        Ok(order)
    }
}
```

---

## Unit Test with #[cfg(test)]

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn calculates_correct_total_for_multiple_items() {
        let items = vec![
            OrderItem { name: "book".into(), price_in_cents: 1000, quantity: 2 },
            OrderItem { name: "pen".into(), price_in_cents: 250, quantity: 4 },
        ];
        assert_eq!(calculate_total(&items), Ok(3000));
    }

    #[test]
    fn returns_error_when_item_has_zero_price() {
        let items = vec![OrderItem { name: "free".into(), price_in_cents: 0, quantity: 1 }];
        let result = calculate_total(&items);
        assert!(matches!(result, Err(OrderError::InvalidItem(_))));
    }
}
```

---

## Unsafe Block with Documentation

```rust
// Correct: minimal unsafe, documented invariant.

/// Converts a raw pointer back to a Box.
///
/// # Safety
///
/// `ptr` must have been obtained from `Box::into_raw` and must not have been
/// freed or aliased since then. Calling this function transfers ownership back.
pub unsafe fn reclaim_boxed<T>(ptr: *mut T) -> Box<T> {
    // SAFETY: caller guarantees the pointer is valid and exclusively owned.
    Box::from_raw(ptr)
}
```

---

## Iterator Usage

```rust
// Prefer iterators over manual loops for transformations.
fn total_in_cents(items: &[OrderItem]) -> i64 {
    items.iter()
        .map(|item| item.price_in_cents * item.quantity as i64)
        .sum()
}

// Filtering and collecting:
fn active_orders(orders: &[Order]) -> Vec<&Order> {
    orders.iter()
        .filter(|o| o.status == OrderStatus::Active)
        .collect()
}
```

---

## Over-Engineering vs. Simplicity

### Overly complex (avoid)

```rust
// A trait with one implementation and no testability benefit.
trait TotalCalculator {
    fn calculate(&self, items: &[OrderItem]) -> i64;
}

struct StandardTotalCalculator;

impl TotalCalculator for StandardTotalCalculator {
    fn calculate(&self, items: &[OrderItem]) -> i64 {
        items.iter().map(|i| i.price_in_cents * i.quantity as i64).sum()
    }
}
```

### Simplified (prefer)

```rust
// A function is sufficient when there is one implementation.
fn calculate_total(items: &[OrderItem]) -> i64 {
    items.iter().map(|i| i.price_in_cents * i.quantity as i64).sum()
}
```

---

## Option and Result Combinators

```rust
// Chaining combinators to transform and propagate.
fn display_name(user: &User) -> String {
    user.profile
        .as_ref()
        .and_then(|p| p.display_name.as_deref())
        .unwrap_or("Anonymous")
        .to_string()
}

// Converting Option to Result with a meaningful error:
fn find_required(orders: &[Order], id: &OrderId) -> Result<&Order, OrderError> {
    orders.iter()
        .find(|o| &o.id == id)
        .ok_or_else(|| OrderError::NotFound(id.clone()))
}
```

---

## Rust-Specific Anti-Patterns

### unwrap() in Production Path

```rust
// Anti-pattern: panics at runtime when the user is not found.
let user = repository.find_by_id(&id).unwrap();

// Correct: propagate the error.
let user = repository.find_by_id(&id)
    .await?
    .ok_or_else(|| UserError::NotFound(id.clone()))?;
```

### Clone to Avoid Borrow Checker

```rust
// Anti-pattern: clones unnecessarily to avoid thinking about ownership.
fn process(orders: &[Order]) -> Vec<String> {
    orders.iter()
        .map(|o| o.customer_id.clone()) // clone just because it compiles
        .collect()
}

// Correct: borrow the str slice — no allocation needed.
fn process(orders: &[Order]) -> Vec<&str> {
    orders.iter()
        .map(|o| o.customer_id.as_str())
        .collect()
}
```

### Undocumented unsafe Block

```rust
// Anti-pattern: no explanation of the invariant being upheld.
unsafe {
    std::ptr::write(ptr, value);
}

// Correct: document what invariant makes this safe.
// SAFETY: `ptr` was obtained from `Box::into_raw` and has not been
// freed or aliased. Writing to it here completes the initialization.
unsafe {
    std::ptr::write(ptr, value);
}
```

### Converting All Errors to String

```rust
// Anti-pattern: all error type information is lost.
fn find_order(id: &str) -> Result<Order, String> {
    repository.find(id).map_err(|e| e.to_string())
}

// Correct: preserve the error type.
fn find_order(id: &str) -> Result<Order, OrderError> {
    repository.find(id).map_err(OrderError::Repository)
}
```

### Trait for One Implementation Without Testability Benefit

```rust
// Anti-pattern: trait with one impl and no test double.
trait TotalCalculator {
    fn calculate(&self, items: &[OrderItem]) -> i64;
}
struct DefaultTotalCalculator;
impl TotalCalculator for DefaultTotalCalculator {
    fn calculate(&self, items: &[OrderItem]) -> i64 {
        items.iter().map(|i| i.price_in_cents * i.quantity as i64).sum()
    }
}

// Correct: a function is sufficient when there is only one implementation.
fn calculate_total(items: &[OrderItem]) -> i64 {
    items.iter().map(|i| i.price_in_cents * i.quantity as i64).sum()
}
```

---

## Async Handler (Axum Example)

```rust
use axum::{extract::{Path, State}, http::StatusCode, Json};

async fn get_order(
    State(service): State<Arc<OrderService<impl OrderRepository>>>,
    Path(order_id): Path<String>,
) -> Result<Json<OrderResponse>, StatusCode> {
    let id = OrderId::parse(&order_id).map_err(|_| StatusCode::BAD_REQUEST)?;

    match service.get_order(&id).await {
        Ok(order) => Ok(Json(OrderResponse::from(order))),
        Err(OrderError::NotFound(_)) => Err(StatusCode::NOT_FOUND),
        Err(_) => Err(StatusCode::INTERNAL_SERVER_ERROR),
    }
}
```
