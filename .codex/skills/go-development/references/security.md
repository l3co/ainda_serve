# Go Security Guidance

## General Posture

Security is not a post-processing step. Review every change against this checklist before declaring a task complete. Flag any concern found — even if the task did not explicitly mention security.

## Input Validation

- Validate all external input at the system boundary (HTTP handlers, CLI args, message consumers).
- Define maximum sizes for strings, slices, and uploaded content. Reject input that exceeds them.
- Do not pass user-controlled strings to `fmt.Sprintf` as format strings — use `%s` with an argument:
  ```go
  // Incorrect — format string injection:
  fmt.Sprintf(userInput)
  
  // Correct:
  fmt.Sprintf("%s", userInput)
  ```
- Reject or sanitize characters that are meaningful in shell, SQL, HTML, or file paths before using them.

## SQL Injection

Always use parameterized queries. Never interpolate user input into SQL strings:

```go
// Incorrect:
query := "SELECT * FROM users WHERE email = '" + email + "'"
rows, err := db.QueryContext(ctx, query)

// Correct:
rows, err := db.QueryContext(ctx, "SELECT * FROM users WHERE email = $1", email)
```

This applies to all database drivers (`database/sql`, `pgx`, `sqlx`, ORM query builders).

## Command Injection

Avoid `exec.Command` with shell expansion. If you must run a subprocess:

```go
// Incorrect — shell injection possible:
exec.Command("sh", "-c", "grep " + userInput + " /var/log/app.log")

// Correct — no shell; arguments are separate:
exec.Command("grep", "--", userInput, "/var/log/app.log")
```

Never pass user-controlled input as a shell command string.

## Path Traversal

When using user-provided file paths, validate them against an allowed base directory:

```go
func safePath(base, userPath string) (string, error) {
    abs, err := filepath.Abs(filepath.Join(base, userPath))
    if err != nil {
        return "", err
    }
    if !strings.HasPrefix(abs, filepath.Clean(base)+string(os.PathSeparator)) {
        return "", fmt.Errorf("path traversal detected")
    }
    return abs, nil
}
```

## Race Conditions

Run the race detector in CI: `go test -race ./...`

Protect shared mutable state with `sync.Mutex` or `sync.RWMutex`. Document which fields each mutex protects.

## HTTP Security

- Always set read/write timeouts on `http.Server`:
  ```go
  server := &http.Server{
      ReadTimeout:  5 * time.Second,
      WriteTimeout: 10 * time.Second,
      IdleTimeout:  120 * time.Second,
  }
  ```
- Reject requests with bodies larger than the expected maximum using `http.MaxBytesReader`.
- Configure TLS with a minimum version of TLS 1.2:
  ```go
  tlsConfig := &tls.Config{MinVersion: tls.VersionTLS12}
  ```
- Set security headers: `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy` — typically via middleware.

## Secrets Management

- Never store secrets (passwords, API keys, tokens, private keys) in source code or configuration files committed to version control.
- Load secrets from environment variables or a secrets manager (Vault, AWS Secrets Manager, etc.).
- Do not log secret values, even at debug level.
- Do not include secrets in error messages returned to clients.

## JSON Deserialization

- Use `json.Decoder` with `DisallowUnknownFields()` when deserializing into known types:
  ```go
  dec := json.NewDecoder(r.Body)
  dec.DisallowUnknownFields()
  if err := dec.Decode(&payload); err != nil {
      http.Error(w, "invalid request", http.StatusBadRequest)
      return
  }
  ```
- Set a maximum body size before decoding: `r.Body = http.MaxBytesReader(w, r.Body, 1<<20)`.

## Denial of Service

- Rate-limit incoming requests on public endpoints.
- Set timeouts on all outgoing HTTP and database calls.
- Use `context.WithTimeout` for all I/O-bound operations.
- Limit goroutine fan-out with a semaphore or worker pool when processing user-driven concurrency.

## Dependency Security

- Run `govulncheck ./...` (from `golang.org/x/vuln`) in CI to detect known vulnerabilities in dependencies.
- Keep dependencies up to date. Review changelogs when updating.
- Do not use `replace` directives in `go.mod` that point to unverified forks.

## Error Exposure

- Do not return internal error details (stack traces, database errors, file paths) to API clients.
- Log the full error internally; return a generic message externally:
  ```go
  log.Printf("internal error creating user: %v", err)
  http.Error(w, "internal server error", http.StatusInternalServerError)
  ```

## Security Review Checklist

Before completing any task that touches HTTP handlers, database access, file I/O, or external input:

- [ ] All SQL queries use parameterized arguments
- [ ] No user input is interpolated into shell commands
- [ ] File paths from user input are validated against allowed directories
- [ ] HTTP server has read/write timeouts configured
- [ ] Request body size is limited before parsing
- [ ] No secrets are in source code
- [ ] No internal error details are exposed to API clients
- [ ] Race detector passes (`go test -race`) on affected packages
- [ ] `govulncheck` reports no critical vulnerabilities in new or updated dependencies
