# Rust-Specific Guardrails

These guardrails apply to all agents working on Rust codebases. They extend — not replace — the shared guardrails in `../shared/guardrails.md`. In any conflict, the shared guardrails take precedence unless noted here.

---

## Error Handling

MUST NOT use `.unwrap()` in production code paths — use `?`, `.ok_or_else()`, or explicit `match`.

MUST NOT use `.expect("message")` in library code — use proper error propagation.

MAY use `.unwrap()` and `.expect()` in tests where a failure means the test setup is broken.

MUST NOT use `panic!` for recoverable errors — reserve it for invariant violations that represent bugs.

MUST propagate errors using the `?` operator and compose error types with `thiserror` or compatible crates.

MUST NOT convert all errors to `String` or `Box<dyn Error>` at the boundary of every function — preserve error types for callers that need to match on them.

SHOULD use a domain-specific error enum per module with `#[derive(Debug, thiserror::Error)]`.

---

## Ownership and Borrowing

MUST NOT clone a value solely to avoid a borrow checker constraint — rethink ownership if cloning is the only solution.

MUST NOT use `.clone()` on large data structures in hot paths without profiling justification.

SHOULD prefer borrowing over cloning for read-only access.

MUST NOT hold a `Mutex` lock across an `await` point.

MUST NOT use `Rc` in async contexts — use `Arc`.

MUST NOT use `RefCell` in multithreaded contexts — use `Mutex` or `RwLock`.

---

## Unsafe Code

MUST NOT write `unsafe` code without a `// SAFETY:` comment immediately above the block.

The `// SAFETY:` comment MUST describe the specific invariant that makes the operation safe.

MUST minimize the scope of every `unsafe` block to the smallest possible expression.

MUST NOT expand `unsafe` scope to avoid a borrow checker conflict — rethink the design instead.

MUST document all invariants that callers of an `unsafe fn` must uphold in a `# Safety` section in the doc comment.

MUST NOT use `transmute` when a safe alternative exists.

MUST audit all `unsafe` blocks when they are modified — changing one line may break the invariant.

---

## Traits and Abstractions

MUST NOT define traits with a single implementation when a concrete type or function would suffice.

SHOULD define traits at the consumer, not the provider.

MUST NOT create trait objects (`dyn Trait`) without evaluating whether generics (`impl Trait` or `<T: Trait>`) would serve better.

MUST NOT implement `Display` for types that are not meant to be shown to end users — use `Debug` for internal inspection.

SHOULD implement `std::error::Error` for all error types used in `Result` returns.

MUST NOT add `Clone`, `Copy`, `PartialEq`, or `Hash` derives blindly — evaluate whether the type should support those operations.

---

## Async

MUST NOT use `std::thread::sleep` in async code — use the async runtime's sleep (e.g., `tokio::time::sleep`).

MUST NOT block a thread inside an async context with synchronous I/O — use async alternatives.

MUST use `tokio::spawn` or equivalent only when you can track the task's lifecycle and termination.

MUST NOT ignore `JoinHandle` from spawned tasks when their failure matters.

MUST cancel or await all spawned tasks before the owning scope exits.

MUST NOT hold a `std::sync::Mutex` across an `await` — use `tokio::sync::Mutex` for async-compatible locking.

---

## Testing

MUST use `#[cfg(test)]` modules for unit tests within the same file as the code under test.

SHOULD put integration tests in the `tests/` directory.

MUST use `#[tokio::test]` (or the runtime's equivalent) for async tests.

MUST NOT use global mutable state in tests — use dependency injection and locally constructed values.

MUST NOT use `std::thread::sleep` in tests — control time with mock clocks or channel signaling.

SHOULD write benchmarks in `benches/` using `criterion` for performance-sensitive code.

MUST NOT use `cargo test -- --nocapture` to hide test failures — all output should be visible in CI.

---

## Dependencies and Features

MUST NOT add a crate for functionality available in the standard library.

SHOULD use optional features (`[features]`) to guard large optional dependencies.

MUST NOT enable all features of a dependency by default — opt in to what is needed.

MUST NOT ignore `cargo audit` warnings for security advisories in published crates.

MUST pin major versions in `Cargo.toml` and review breaking changes before updating.

MUST NOT add `build.rs` scripts that download content at build time without necessity and documentation.

---

## Security (Rust-Specific)

MUST use parameterized queries when interacting with databases — never format user input into SQL strings.

MUST NOT use `std::process::Command` with shell interpolation of user input — use a fixed argument list.

MUST validate file paths against an expected root before reading or writing to prevent path traversal.

MUST use `rand::rngs::OsRng` or `getrandom` for security-critical random values — not `rand::thread_rng()` alone.

MUST NOT serialize secrets into log output via `Debug` derives — use a custom `Debug` implementation that masks sensitive fields.

MUST NOT expose `panic` backtraces in production API responses.

MUST review all `unsafe` blocks for TOCTOU and aliasing risks.

---

## Observability

SHOULD use the `tracing` crate for structured, async-aware logging and spans.

MUST NOT use `println!` for operational logging.

SHOULD instrument async functions with `#[tracing::instrument]` when they are significant operations.

MUST NOT include sensitive fields in `#[tracing::instrument]` fields — use `skip(secret_field)`.

MUST NOT log secrets, tokens, or personal data — derive `Debug` carefully for types that hold sensitive values.

SHOULD propagate `tracing::Span` context across async task boundaries using `Span::in_scope` or `instrument()`.

---

## Code Style Guardrails

MUST NOT ignore `clippy` lints without a documented `#[allow(...)]` reason.

MUST NOT suppress compiler warnings with `#[allow(warnings)]` on modules.

MUST use `rustfmt` formatting — do not manually reformat code that `rustfmt` would handle differently.

MUST NOT use deprecated APIs without a migration plan.

MUST NOT write `as` casts for integer narrowing without checking for truncation risk.
