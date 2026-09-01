# Go Conventions

## Naming

- Use short, contextual names for local variables: `r` for `*http.Request`, `w` for `http.ResponseWriter`, `ctx` for `context.Context`, `err` for errors.
- Use longer, descriptive names for exported types and functions: `UserRepository`, `ParseConfig`, `OrderService`.
- Acronyms are all-caps: `ID`, `URL`, `HTTP`, `API` — not `Id`, `Url`, `Http`.
- Package names are lowercase, singular, and descriptive: `user`, `order`, `config`, `store`. Not `users`, `helpers`, `utils`, `common`.
- Interface names often end with `-er` when they represent a behavior: `Reader`, `Writer`, `Stringer`, `UserFinder`.
- All identifiers must be in English.
- Avoid generic names: `data`, `info`, `item`, `object`, `manager`, `handler`, `processor`.

## File Organization

- Group related types, functions, and methods in the same file.
- Split files by responsibility, not alphabetically or by type category.
- Test files live in the same package and directory: `user_test.go` alongside `user.go`.
- External (black-box) tests use the `_test` package suffix: `package user_test`.

## Package Structure

- One package per directory.
- A package exports only what external consumers genuinely need.
- Unexported identifiers are the default — export only at package boundaries.
- Avoid `init()` unless necessary for initialization that cannot be expressed otherwise.
- Do not use package-level mutable variables for application state.

## Error Handling

- Always check returned errors. Never assign to `_` without a comment explaining why.
- Wrap errors with context at each meaningful boundary:
  ```go
  if err != nil {
      return fmt.Errorf("createUser: %w", err)
  }
  ```
- Use `errors.Is` and `errors.As` to check error types — do not compare error strings.
- Define sentinel errors as package-level variables:
  ```go
  var ErrNotFound = errors.New("not found")
  ```
- Define error types for structured errors that need to carry additional data:
  ```go
  type ValidationError struct {
      Field   string
      Message string
  }
  func (e *ValidationError) Error() string {
      return fmt.Sprintf("validation error: %s: %s", e.Field, e.Message)
  }
  ```
- Do not use `panic` for expected errors. Reserve `panic` for programmer errors (broken invariants) and initialization failures where recovery is impossible.
- Do not log and return the same error — choose one or the other at each level.
- Error messages must be in English and must not begin with a capital letter or end with punctuation.

## Interfaces

- Define interfaces in the consuming package.
- Prefer interfaces with one or two methods.
- Do not define interfaces preemptively — define them when a second implementation exists or when testability explicitly requires it.
- Accept interfaces, return concrete types (unless the concrete type would create a package cycle or testability problem).

## Dependency Management

- Use `go mod tidy` to keep `go.mod` and `go.sum` consistent.
- Pin the minimum required Go version in `go.mod`.
- Prefer the standard library over third-party packages for common tasks.
- Before adding a dependency, verify: Is it maintained? Is the license compatible? Does the project already have an equivalent? Is it sized appropriately for the task?
- Use `go mod vendor` only if the project already uses vendoring — do not introduce it unilaterally.

## Immutability and State

- Prefer returning new values over mutating in place.
- Use value receivers when the method does not need to mutate the receiver and the type is small.
- Use pointer receivers consistently within a type — do not mix.
- Avoid package-level mutable variables for application behavior. Use dependency injection instead.

## Concurrency

- Use goroutines only when parallelism or asynchronous I/O provides a measurable benefit.
- Always define how a goroutine terminates: via context cancellation, a done channel, or a `WaitGroup`.
- Share memory by communicating (channels) rather than communicating by sharing memory (mutexes) when the design is cleaner. Use mutexes when they are more appropriate.
- Protect shared state with `sync.Mutex` or `sync.RWMutex`. Document which fields a mutex protects.
- Use `sync/atomic` only for simple counter operations — not for complex state management.
- Prefer `errgroup.Group` (from `golang.org/x/sync/errgroup`) for fan-out patterns with error collection.
- Always pass `context.Context` to goroutines that do I/O, so they can be cancelled.

## Context

- `context.Context` is the first parameter of any function that may block or need cancellation.
- Never store a `Context` in a struct — pass it as a function parameter.
- Use `context.WithTimeout` or `context.WithDeadline` for external calls.
- Use `context.WithValue` sparingly, only for request-scoped data (trace IDs, auth tokens) — not for passing optional parameters.

## Zero Values

- Design types so their zero value is meaningful and safe to use:
  ```go
  var buf bytes.Buffer  // immediately usable
  var mu sync.Mutex     // immediately usable
  ```
- Document the zero-value behavior in the type's comment when it matters.

## Formatting

- Use `gofmt` or `goimports` — the format is non-negotiable.
- Do not configure alternative formatters — the Go community standard is `gofmt`.
- Use `goimports` to also manage import grouping.

## Linting

- Use `go vet` before every commit — it catches real bugs.
- Use `golangci-lint` if configured in the project. Respect the existing lint configuration; do not change it without a documented reason.
- Common enabled linters: `errcheck`, `govet`, `staticcheck`, `ineffassign`, `unused`.

## Observability

### Structured Logging

Use `log/slog` (Go 1.21+) for structured, leveled logging:

```go
import "log/slog"

// Structured log with attributes:
slog.Info("order created",
    "order_id", order.ID,
    "customer_id", order.CustomerID,
    "total_in_cents", order.Total,
)

slog.Error("failed to save order",
    "order_id", order.ID,
    "error", err,
)
```

Pass a logger via `context.Context` or as a dependency — do not use a package-level logger for code that needs to be tested:

```go
func (s *OrderService) Create(ctx context.Context, cmd CreateOrderCommand) (Order, error) {
    log := slog.With("operation", "order.create", "customer_id", cmd.CustomerID)
    log.Info("creating order")
    // ...
}
```

Rules:
- Log at the appropriate level: `Debug` for internal state, `Info` for significant events, `Warn` for recoverable issues, `Error` for failures.
- Do not log and return the same error — choose one per level.
- Never log passwords, tokens, or PII — even at `Debug` level.
- Include a correlation/request ID in log entries for distributed tracing.
- Use `slog.Default()` only for `main` and initialization code.

### Tracing

When using distributed tracing (OpenTelemetry, Jaeger):

- Start a span for each significant operation: HTTP handler, database query, external call.
- Propagate `context.Context` so spans are linked correctly across function calls.
- Add span attributes for key business identifiers (`order_id`, `customer_id`).
- Use `trace.SpanFromContext(ctx)` to access the current span.

### Metrics

Use Prometheus client or OpenTelemetry metrics for:

- Request counts and latency histograms on HTTP handlers
- Error rate counters
- Queue depths and processing times for background workers

Do not add metrics to pure domain functions — instrument at the boundary (handler, adapter).

## Patterns to Avoid

- `utils` or `helpers` packages
- Large interfaces mirroring an entire concrete type
- Interfaces defined in the providing package
- `panic` for expected errors
- `recover` without re-panicking or clear documentation
- Goroutines without a termination strategy
- Global mutable state for application logic
- Getters and setters (idiomatic Go uses direct field access for exported fields)
- OOP inheritance patterns applied artificially (deep embedding hierarchies)
- Java-style factory patterns without a Go-specific reason
