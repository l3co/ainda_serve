# Go-Specific Guardrails

These guardrails apply to all agents working on Go codebases. They extend — not replace — the shared guardrails in `../shared/guardrails.md`. In any conflict, the shared guardrails take precedence unless noted here.

---

## Error Handling

MUST NOT use `_` to discard error return values from functions that can fail.

MUST NOT use `panic` for expected errors or recoverable conditions.

MUST NOT call `log.Fatal` or `os.Exit` outside of `main` or test setup unless the process genuinely cannot continue.

MUST wrap errors with context using `fmt.Errorf("operation: %w", err)` so the error chain is traceable.

MUST NOT expose internal Go error types (e.g., `*url.Error`, `*os.PathError`) directly to external callers.

SHOULD use sentinel errors (`var ErrNotFound = errors.New(...)`) for expected conditions callers can match.

SHOULD use custom error types when callers need to inspect error fields.

---

## Goroutines and Concurrency

MUST document goroutine ownership: who starts it, who owns it, and how it terminates.

MUST NOT start a goroutine without a documented termination path.

MUST NOT leak goroutines that block indefinitely on channels or I/O.

MUST use `context.Context` to propagate cancellation through all blocking operations.

MUST honor context cancellation — do not continue after `ctx.Err()` is non-nil.

MUST NOT share mutable state between goroutines without synchronization.

SHOULD use `sync.WaitGroup` or `errgroup.Group` for fan-out patterns.

SHOULD prefer channels for coordination; prefer mutexes for shared state.

MUST NOT create goroutines in `init()` or package-level `var` blocks.

---

## Interfaces

MUST NOT define interfaces at the provider side.

SHOULD define interfaces at the consumer — in the package that uses the behavior, not the package that provides it.

MUST NOT create interfaces with a single implementation unless testability, mocking, or an explicit architectural boundary justifies it.

MUST NOT create interfaces that duplicate existing standard library interfaces (`io.Reader`, `io.Writer`, etc.) without a reason.

SHOULD accept interfaces and return concrete types.

---

## Packages and Modules

MUST NOT create circular imports.

MUST NOT place domain logic in `main` or in packages named `util`, `common`, `shared`, or `helpers`.

SHOULD follow the standard project layout conventions already established in the project.

MUST NOT use `init()` for logic that has side effects unless the package pattern already depends on it.

MUST NOT use global mutable variables for dependency injection — use constructor functions.

---

## Testing

MUST use table-driven tests for multiple input cases.

MUST write subtests with `t.Run("description", func(t *testing.T) { ... })` for clarity.

MUST NOT depend on test execution order.

MUST NOT sleep in tests to wait for goroutines — use channels, `WaitGroup`, or `sync/atomic`.

SHOULD use `t.Cleanup` to release resources tied to a test.

MUST NOT use `t.Fatal` after a goroutine has started — use `t.Error` and signal termination.

MUST NOT assert on pointers or interfaces that satisfy equal-by-identity semantics without care.

SHOULD test error paths, not only happy paths.

---

## Memory and Allocation

MUST NOT return a pointer to a local variable when a value would suffice and the caller does not need mutation.

MUST NOT prematurely optimize allocation patterns without profiling evidence.

SHOULD prefer value types for small, immutable data.

SHOULD use `sync.Pool` only when profiling confirms allocation pressure.

MUST NOT retain references to large buffers unnecessarily after use.

---

## Security (Go-Specific)

MUST use parameterized queries or an ORM's parameter binding — never interpolate user input into SQL.

MUST NOT construct shell commands with `exec.Command` by concatenating user input — use a fixed argument list.

MUST validate file paths against an allowed base directory before reading or writing to prevent path traversal.

MUST set appropriate timeouts on `http.Client` — never use the default client for outbound requests.

MUST NOT disable TLS verification (`InsecureSkipVerify: true`) in production code.

MUST use `crypto/rand` for random values where security properties are required — not `math/rand`.

MUST NOT use `md5` or `sha1` for cryptographic purposes.

MUST NOT log request bodies or parameters that may contain credentials or PII.

---

## Observability

SHOULD use `log/slog` (Go 1.21+) with structured, key-value log statements.

SHOULD include `context.Context` in all log calls to propagate correlation IDs.

MUST NOT log sensitive data (credentials, personal identifiers, request bodies with PII).

SHOULD emit consistent field names across log calls (e.g., `"order_id"`, `"customer_id"`, `"error"`).

MUST NOT log the same error at multiple layers without necessity.

SHOULD record spans for operations that cross service boundaries.

---

## Code Style Guardrails

MUST NOT use named return values to hide complex control flow.

MUST NOT add unnecessary blank interfaces (`interface{}`/`any`) where a typed interface is feasible.

MUST use `defer` for cleanup, but MUST NOT rely on `defer` for critical-path performance-sensitive cleanup.

MUST NOT shadow the built-in `error` identifier with a local variable or type.

MUST NOT import packages solely for their side effects without a comment explaining why.
