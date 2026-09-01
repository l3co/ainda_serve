# Rust Security Guidance

## General Posture

Rust's type system and ownership model eliminate entire classes of vulnerabilities (buffer overflows, use-after-free, data races) at compile time. However, Rust programs can still have logic vulnerabilities, injection attacks, unsafe code issues, and dependency vulnerabilities. Review every change against this checklist before declaring a task complete.

## Unsafe Code

`unsafe` is the highest-risk construct in Rust. Every `unsafe` block requires:

1. A comment explaining exactly which invariant is being upheld.
2. A justification for why a safe alternative is insufficient.
3. Isolation in a minimal scope — never place safe code inside `unsafe` blocks unnecessarily.
4. A safe public wrapper that enforces the invariant at the type level.
5. Tests that verify the invariant holds.

Audit all existing `unsafe` blocks in code you are modifying. If you touch surrounding logic, verify that the unsafe invariant still holds.

## Integer Overflow

Rust panics on integer overflow in debug mode but wraps silently in release mode. For business-critical arithmetic:

```rust
// Risky in release mode — wraps silently:
let total = price * quantity;

// Safe — returns None on overflow:
let total = price.checked_mul(quantity).ok_or(OrderError::Overflow)?;

// Or use saturating arithmetic when wrapping is acceptable:
let total = price.saturating_mul(quantity);
```

Use `checked_*` methods for financial calculations, byte offsets, or any arithmetic where overflow is a correctness or security concern.

## SQL Injection

When using `sqlx`, `diesel`, or similar crates, always use parameterized queries:

```rust
// Correct with sqlx:
let user = sqlx::query_as::<_, User>(
    "SELECT * FROM users WHERE email = $1"
)
.bind(&email)
.fetch_optional(&pool)
.await?;

// Incorrect — SQL injection risk (never do this):
let query = format!("SELECT * FROM users WHERE email = '{}'", email);
sqlx::query(&query).fetch_optional(&pool).await?;
```

Never format user-controlled strings into SQL queries.

## Command Injection

When using `std::process::Command`, pass arguments separately — never use a shell with user input:

```rust
// Correct — arguments are separate, no shell interpretation:
let output = Command::new("grep")
    .arg("--")
    .arg(&user_pattern)
    .arg("/var/log/app.log")
    .output()?;

// Incorrect — shell injection possible:
Command::new("sh")
    .arg("-c")
    .arg(format!("grep {} /var/log/app.log", user_pattern))
    .output()?;
```

## Path Traversal

Validate user-provided paths against an allowed base directory:

```rust
use std::path::{Path, PathBuf};

fn safe_path(base: &Path, user_input: &str) -> Result<PathBuf, SecurityError> {
    let target = base.join(user_input).canonicalize()
        .map_err(|_| SecurityError::InvalidPath)?;
    if !target.starts_with(base.canonicalize()?) {
        return Err(SecurityError::PathTraversal);
    }
    Ok(target)
}
```

## Secrets Management

- Never store secrets (API keys, passwords, tokens) in source code or committed configuration files.
- Load secrets from environment variables using `std::env::var` or a secrets manager.
- Do not log secret values, even at `debug!` level.
- Do not include secrets in error messages returned to callers.

```rust
let api_key = std::env::var("API_KEY")
    .map_err(|_| ConfigError::MissingEnvVar("API_KEY"))?;
```

## Deserialization with Serde

- Use `#[serde(deny_unknown_fields)]` when deserializing untrusted input into known types:
  ```rust
  #[derive(Deserialize)]
  #[serde(deny_unknown_fields)]
  struct CreateOrderRequest {
      customer_id: String,
      items: Vec<OrderItem>,
  }
  ```
- Set a maximum recursion depth when deserializing nested JSON from untrusted sources.
- Validate the deserialized struct after deserialization — serde guarantees types, not business rules.

## HTTP Security

When building HTTP servers (Axum, Actix, Warp, Hyper):

- Set timeouts on all incoming request handlers.
- Limit request body size before reading the full body.
- Set security headers: `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`.
- Use TLS in production; never accept plaintext HTTP for authenticated endpoints.
- Validate `Content-Type` headers before parsing request bodies.

## Dependency Security

- Run `cargo audit` in CI:
  ```sh
  cargo install cargo-audit
  cargo audit
  ```
- Subscribe to RustSec advisories for critical libraries you depend on.
- Keep dependencies up to date. Use `cargo update` and review changelogs.
- Audit the `unsafe` usage of new dependencies: `cargo geiger` reports unsafe counts.
- Prefer well-maintained crates from the ecosystem (Tokio, Serde, Axum, sqlx) over obscure alternatives.

## Error Exposure

Do not return internal Rust error messages, file paths, or `Debug` representations to external clients:

```rust
// Incorrect — exposes internal detail:
Err(e) => HttpResponse::InternalServerError().body(format!("{:?}", e))

// Correct — generic external message, full internal log:
Err(e) => {
    tracing::error!("order creation failed: {:?}", e);
    HttpResponse::InternalServerError().body("internal server error")
}
```

## Timing Attacks

When comparing secrets (tokens, hashes), use constant-time comparison to prevent timing attacks:

```rust
use subtle::ConstantTimeEq;

fn verify_token(expected: &[u8], actual: &[u8]) -> bool {
    expected.ct_eq(actual).into()
}
```

Do not use `==` for secret comparison.

## Security Review Checklist

Before completing any task involving network I/O, database access, file handling, or untrusted input:

- [ ] All SQL queries use parameterized binding — no string formatting into SQL
- [ ] `Command` invocations do not pass user input through a shell
- [ ] File paths from user input are validated against allowed base directories
- [ ] Integer arithmetic in financial or security-critical paths uses `checked_*` methods
- [ ] Every `unsafe` block has a documented invariant and a safe wrapper
- [ ] No secrets in source code or committed configuration files
- [ ] Error responses do not expose `Debug` output or internal details to clients
- [ ] Secret comparison uses constant-time equality
- [ ] `cargo audit` reports no critical vulnerabilities in new or updated dependencies
- [ ] `#[serde(deny_unknown_fields)]` used for untrusted deserialization targets
