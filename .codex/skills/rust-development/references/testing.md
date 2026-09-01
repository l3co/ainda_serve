# Rust Testing Strategy

## Philosophy

Test observable behavior — what a function or module does from the outside — not internal implementation details. A test that breaks when you rename a private helper is testing the wrong thing. A test that breaks when the public contract changes is doing its job.

## Test Organization

Rust has three natural testing layers:

1. **Unit tests**: in `#[cfg(test)]` modules inside the source file
2. **Integration tests**: in `tests/` directory (test the public API of the crate)
3. **Doc tests**: code examples in documentation comments (`///`)

```
src/
├── lib.rs
├── order/
│   ├── mod.rs
│   └── service.rs     ← unit tests at the bottom in #[cfg(test)]
└── ...

tests/
├── order_flow.rs      ← integration tests
└── common/
    └── mod.rs         ← shared test helpers
```

## Unit Tests

Unit tests live in a `#[cfg(test)]` module at the bottom of the same file:

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn calculates_total_with_standard_items() {
        let items = vec![
            OrderItem { name: "book".into(), price_in_cents: 1000, quantity: 2 },
            OrderItem { name: "pen".into(), price_in_cents: 200, quantity: 3 },
        ];
        let total = calculate_total(&items).unwrap();
        assert_eq!(total, 2600);
    }

    #[test]
    fn returns_error_when_item_has_zero_price() {
        let items = vec![OrderItem { name: "free".into(), price_in_cents: 0, quantity: 1 }];
        let result = calculate_total(&items);
        assert!(result.is_err());
    }
}
```

Unit tests may test private functions because they live in the same module.

## Integration Tests

Integration tests in `tests/` have access only to the crate's public API:

```rust
// tests/order_flow.rs
use my_service::{OrderService, CreateOrderCommand};

#[tokio::test]
async fn creates_order_and_persists_it() {
    let repo = FakeOrderRepository::new();
    let service = OrderService::new(repo.clone());
    let command = CreateOrderCommand {
        customer_id: "cust-1".to_string(),
        items: vec![/* ... */],
    };

    let order = service.create_order(command).await.unwrap();

    let stored = repo.find_by_id(&order.id).await.unwrap();
    assert_eq!(stored.customer_id, "cust-1");
}
```

## Doc Tests

Doc tests verify that examples in documentation actually work:

```rust
/// Calculates the total price in cents for a list of order items.
///
/// # Examples
///
/// ```
/// use my_service::{calculate_total, OrderItem};
///
/// let items = vec![OrderItem { name: "book".into(), price_in_cents: 500, quantity: 2 }];
/// assert_eq!(calculate_total(&items).unwrap(), 1000);
/// ```
pub fn calculate_total(items: &[OrderItem]) -> Result<i64, OrderError> {
    // ...
}
```

Write doc tests for all public functions that have non-trivial usage.

## Test Doubles

Rust's type system enables clean, hand-written fakes without a mocking framework:

```rust
// A hand-written in-memory repository:
#[derive(Clone, Default)]
pub struct FakeOrderRepository {
    orders: Arc<Mutex<HashMap<OrderId, Order>>>,
}

#[async_trait]
impl OrderRepository for FakeOrderRepository {
    async fn find_by_id(&self, id: &OrderId) -> Result<Option<Order>, RepositoryError> {
        Ok(self.orders.lock().unwrap().get(id).cloned())
    }

    async fn save(&self, order: &Order) -> Result<(), RepositoryError> {
        self.orders.lock().unwrap().insert(order.id.clone(), order.clone());
        Ok(())
    }
}
```

Prefer fakes over mocking frameworks (`mockall`, `mockito`). Mocking frameworks are appropriate when:

- The trait has many methods and implementing a fake is impractical
- You need to verify that specific methods were called with specific arguments as part of the contract

## Async Tests

Use the `#[tokio::test]` attribute for async tests:

```rust
#[tokio::test]
async fn sends_notification_after_order_creation() {
    let notification_sender = FakeNotificationSender::new();
    let service = OrderService::new(
        FakeOrderRepository::new(),
        notification_sender.clone(),
    );

    service.create_order(valid_command()).await.unwrap();

    assert_eq!(notification_sender.sent_count(), 1);
}
```

## Naming

Test function names must be in English and describe the scenario:

```rust
fn creates_order_with_correct_total() { ... }
fn returns_error_when_item_list_is_empty() { ... }
fn propagates_repository_error_on_save_failure() { ... }
fn does_not_send_notification_when_order_creation_fails() { ... }
```

## What to Test

Prioritize:

- Business rules and domain invariants
- `Err` and `None` return paths
- Boundary conditions: empty collections, overflow values, zero values
- Trait implementations for correctness
- Critical integration paths (repository queries, external service calls)
- Regressions — every bug fix should add a test

Do not test:

- Internal private functions that have no observable effect on public behavior
- The borrow checker (it is a compile-time guarantee)
- Standard library functions and Rust primitives
- Derived implementations (`#[derive(Debug, Clone)]`) when there is no custom logic

## Coverage

Use coverage as a diagnostic tool:

```sh
cargo llvm-cov --html           # requires cargo-llvm-cov
cargo tarpaulin --out Html      # alternative
```

Focus coverage effort on the business logic and domain rules, not on configuration and glue code.

## Running Tests

```sh
cargo test                            # all tests
cargo test order                      # tests matching "order"
cargo test -- --nocapture             # show println output
cargo test --test order_flow          # specific integration test file
cargo test --lib                      # unit tests only
cargo test --doc                      # doc tests only
cargo test -- --test-threads=1        # single-threaded (for tests with shared state)
```

Always run `cargo test` before declaring a task complete. Run `cargo clippy -- -D warnings` to catch additional issues.

## Property-Based Testing

Use `proptest` or `quickcheck` when:

- The function operates on a large input space that is difficult to cover with examples
- You need to verify mathematical properties (commutativity, associativity, identity)
- Fuzzing would benefit correctness guarantees

Do not add property-based testing without a concrete reason — most domain logic is well-covered by example tests.

## Benchmarks

Use `criterion` for performance benchmarks when profiling confirms a bottleneck:

```rust
// benches/order_bench.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn bench_calculate_total(c: &mut Criterion) {
    let items: Vec<OrderItem> = (0..100)
        .map(|i| OrderItem { price_in_cents: i * 10, quantity: 2 })
        .collect();

    c.bench_function("calculate_total_100_items", |b| {
        b.iter(|| calculate_total(black_box(&items)))
    });
}

criterion_group!(benches, bench_calculate_total);
criterion_main!(benches);
```

In `Cargo.toml`:

```toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "order_bench"
harness = false
```

Run: `cargo bench`

Do not add benchmarks unless there is a measured performance concern. Benchmarks add maintenance cost without benefit when correctness is the only requirement.

## Dependency Security Audit

Run `cargo audit` in CI to detect known vulnerabilities in dependencies:

```sh
cargo install cargo-audit
cargo audit
```

For a faster CI check without installation:

```sh
cargo install cargo-deny
cargo deny check advisories
```

`cargo deny` also enforces license policies and duplicate dependency detection. If the project has a `deny.toml`, respect its configuration.

## Faster Test Execution

If the project already uses `cargo-nextest`, prefer it over `cargo test` for its parallel execution and better output:

```sh
cargo nextest run                         # all tests
cargo nextest run --test order_flow       # specific integration test
cargo nextest run -p my-crate            # specific crate in workspace
```

Do not introduce `cargo-nextest` if the project does not already use it — it is an optional improvement.

## Feature Flags in Tests

When the crate has optional features, tests may need to be run with specific features enabled:

```sh
cargo test --features "postgres,metrics"
cargo test --all-features
cargo test --no-default-features
```

If a test requires a feature, gate it:

```rust
#[cfg(feature = "postgres")]
#[tokio::test]
async fn integrates_with_postgres() { ... }
```
