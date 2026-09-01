# Rust Conventions

## Naming

- **Types (structs, enums, traits)**: `PascalCase` — `OrderService`, `UserRepository`, `PaymentError`
- **Functions and methods**: `snake_case` — `calculate_total`, `find_by_id`, `send_notification`
- **Variables and fields**: `snake_case` — `order_total`, `user_id`, `payment_gateway`
- **Constants**: `UPPER_SNAKE_CASE` — `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS`
- **Modules**: `snake_case` — `order`, `user`, `repository`
- **Lifetimes**: short lowercase: `'a`, `'b`, `'conn`
- All identifiers must be in English.
- Avoid generic names: `data`, `info`, `item`, `object`, `manager`, `helper`, `utils`, `processor`.
- Newtypes: `OrderId(Uuid)`, `AmountInCents(i64)` — use descriptive names that model the domain concept.
- Test functions: `snake_case` — `creates_order_with_correct_total`, `returns_error_when_email_is_missing`

## File Organization

- One primary concern per module.
- Complex modules may be split into submodules in a directory: `order/mod.rs`, `order/service.rs`, `order/repository.rs`.
- Integration tests live in `tests/`.
- Unit tests live in `#[cfg(test)]` modules at the bottom of the same file being tested.
- Keep `lib.rs` and `main.rs` thin — they declare the module tree and configure the application, not implement logic.

## Visibility

- Default to private. Export only what external consumers genuinely need.
- Use `pub(crate)` for items needed across modules within the same crate but not externally.
- Use `pub(super)` for items visible only to the parent module.
- Avoid `pub` on implementation details — they become part of the crate's public API.

## Error Handling

- Return `Result<T, E>` for all fallible operations. Never use `panic!` for expected runtime conditions.
- Use `?` for error propagation. Add context at meaningful boundaries:
  ```rust
  let order = repository
      .find_by_id(&order_id)
      .await
      .map_err(|e| OrderError::Repository(e))?;
  ```
- Define error types with `thiserror`:
  ```rust
  #[derive(Debug, thiserror::Error)]
  pub enum OrderError {
      #[error("order not found: {0}")]
      NotFound(OrderId),
      #[error("repository error: {0}")]
      Repository(#[from] RepositoryError),
  }
  ```
- Use `anyhow::Result` for application-level functions where callers only need to know that something failed.
- Never use `unwrap()` or `expect()` in production paths without a documented invariant proving the value is always `Some`/`Ok`.
- Error messages must be in English and begin in lowercase (consistent with Rust stdlib convention).

## Option and Result

- Use `Option<T>` for values that may legitimately be absent.
- Use `Result<T, E>` for operations that may fail.
- Prefer combinator methods over imperative patterns when they improve clarity:
  ```rust
  // Clear:
  let name = user.profile.as_ref().map(|p| p.name.as_str()).unwrap_or("anonymous");
  
  // Avoid deep combinator chains that hurt readability — extract to a function instead.
  ```
- Use `ok_or` / `ok_or_else` to convert `Option` to `Result` with a meaningful error.

## Ownership and Borrowing

- Accept a reference (`&T` or `&mut T`) when the function does not need to own the data.
- Accept ownership (`T`) when the function needs to store or transform the value.
- Return owned values from constructors and transformations.
- Avoid cloning to work around borrow checker issues — instead, restructure ownership or use lifetimes.
- Use `Arc<T>` for shared ownership across threads; `Rc<T>` for single-threaded shared ownership.
- Use `Cell<T>` and `RefCell<T>` sparingly — document why the borrow checker cannot be satisfied statically.

## Traits

- Define traits in the consuming module.
- Keep traits narrow: one to three methods is almost always enough.
- Implement standard traits when they add real value: `Display`, `Debug`, `From`, `Into`, `Iterator`, `Default`.
- Use `Default` for types that have a meaningful zero-state.
- Do not define a trait unless two or more implementations are present or testability requires it.
- Use trait objects (`dyn Trait`) for runtime polymorphism. Use generics for zero-cost static dispatch.

## Generics

- Use generics when the function or type truly works with multiple distinct types.
- Bound generics with the minimum required traits.
- Prefer concrete types over unnecessarily generic APIs when only one type is used.
- Avoid generic parameters that appear only in the `PhantomData` — this usually signals a design problem.

## Unsafe

Every `unsafe` block must:

1. Have a comment explaining the invariant being upheld.
2. Explain why a safe alternative is insufficient.
3. Be as small as possible — do not put safe code inside `unsafe` blocks.
4. Be wrapped in a safe public API that enforces the invariants externally.

```rust
// SAFETY: `ptr` is guaranteed non-null and aligned because it was obtained from
// `Box::into_raw`, which always produces a valid, aligned pointer.
let value = unsafe { Box::from_raw(ptr) };
```

## Mutability

- Prefer immutable bindings. Declare `mut` only when mutation is necessary.
- Use `let mut` for bindings that will be modified.
- Avoid shared mutable state across threads — use `Arc<Mutex<T>>` only when necessary and document the invariant.
- Prefer `Mutex<T>` over `RwLock<T>` unless read-heavy access is confirmed by profiling.

## Concurrency

- Use `tokio` for async I/O in services (or the runtime already chosen by the project).
- Use `rayon` for data parallelism in CPU-bound computations (if the project uses it).
- Ensure types shared across threads are `Send + Sync`.
- Use channels (`tokio::sync::mpsc`, `std::sync::mpsc`) to communicate between concurrent tasks instead of shared mutable state where possible.
- Document which thread owns which data when using `Mutex` or `RwLock`.

## Iterators

- Prefer iterator methods over manual loops for transformations:
  ```rust
  let total: i64 = items.iter().map(|item| item.price_in_cents * item.quantity).sum();
  ```
- Use `collect()` with an explicit type when the type cannot be inferred.
- Implement `Iterator` for custom types that represent a sequence.

## Observability

### Structured Logging with `tracing`

Use the `tracing` crate for structured, async-aware logging:

```rust
use tracing::{info, error, instrument};

#[instrument(fields(customer_id = %command.customer_id))]
pub async fn create_order(command: CreateOrderCommand) -> Result<Order, OrderError> {
    info!("creating order");

    let order = Order::new(&command)?;
    repository.save(&order).await?;

    info!(order_id = %order.id, total_in_cents = order.total_in_cents, "order created");
    Ok(order)
}
```

Set up a subscriber in `main.rs`:

```rust
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

tracing_subscriber::registry()
    .with(EnvFilter::from_default_env())   // RUST_LOG=info,my_crate=debug
    .with(tracing_subscriber::fmt::layer().json())  // structured JSON output
    .init();
```

Rules:
- Use `#[instrument]` on async functions to automatically create spans and attach arguments as fields.
- Use `%value` for `Display` formatting and `?value` for `Debug` formatting in field values.
- Never log passwords, tokens, or PII — even at `DEBUG` level.
- Propagate `tracing` context automatically through `async`/`.await` — spans are scoped to their `Future`.
- Use `error!`, `warn!`, `info!`, `debug!`, `trace!` macros at the appropriate level.

### Metrics

For Prometheus metrics with `metrics` or `prometheus` crate:

```rust
use metrics::{counter, histogram};

pub async fn handle_order_creation(/* ... */) {
    let start = std::time::Instant::now();

    match create_order(command).await {
        Ok(_) => {
            counter!("orders_created_total").increment(1);
            histogram!("order_creation_duration_seconds").record(start.elapsed().as_secs_f64());
        }
        Err(e) => {
            counter!("orders_creation_errors_total").increment(1);
            error!("order creation failed: {:?}", e);
        }
    }
}
```

Instrument at HTTP handlers and adapters — not in pure domain functions.

## Feature Flags

Use Cargo feature flags to enable optional functionality:

```toml
# Cargo.toml
[features]
default = ["postgres"]
postgres = ["dep:sqlx"]
metrics = ["dep:prometheus"]
full = ["postgres", "metrics"]

[dependencies]
sqlx = { version = "0.7", optional = true }
prometheus = { version = "0.13", optional = true }
```

Gate code with `#[cfg(feature = "...")]`:

```rust
#[cfg(feature = "metrics")]
pub fn record_metric(name: &str, value: f64) {
    prometheus::gauge!(name, value);
}

#[cfg(not(feature = "metrics"))]
pub fn record_metric(_name: &str, _value: f64) {}
```

Rules for feature flags:
- Keep `default` features minimal — library users should opt in to optional dependencies.
- Do not gate core domain logic behind features — only optional integrations.
- Test with `--all-features` in CI to catch compilation errors across all combinations.
- Test with `--no-default-features` to verify the minimal build still compiles.
- Document what each feature enables in the `Cargo.toml` comment above the feature.

## Patterns to Avoid

- `unwrap()` and `expect()` in production code paths without documented invariants
- `panic!` for expected, runtime-recoverable conditions
- Cloning to work around borrowing without first trying lifetimes or restructuring
- `unsafe` without isolation, documentation, and a safe wrapper
- Traits with many methods that mirror an entire concrete type's API
- Lifetimes where the compiler can infer them (elision rules cover most common cases)
- Using `String` everywhere when `&str` suffices for borrowed data
- Returning `impl Trait` in public API when the concrete type is needed by callers
- Converting errors to `Box<dyn Error>` at low levels where precise error types matter
