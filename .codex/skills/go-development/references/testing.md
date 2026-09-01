# Go Testing Strategy

## Philosophy

Test observable behavior, not internal implementation. A test that breaks when you rename a private function is testing the wrong thing. A test that breaks when the externally observable behavior changes is doing its job.

## Test Organization

- Test files live in the same directory as the code being tested.
- Use `package foo` (white-box) to access unexported identifiers when needed.
- Use `package foo_test` (black-box) to test the public API in isolation — preferred for most cases.
- Name test files `<file>_test.go` matching the file they primarily test.

## Table-Driven Tests

Table-driven tests are idiomatic Go. Use them whenever you have multiple similar cases:

```go
func TestParseAmount(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int64
        wantErr bool
    }{
        {name: "valid integer", input: "100", want: 100},
        {name: "valid decimal", input: "19.99", want: 1999},
        {name: "empty string returns error", input: "", wantErr: true},
        {name: "negative value returns error", input: "-5", wantErr: true},
    }

    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            got, err := ParseAmount(tc.input)
            if (err != nil) != tc.wantErr {
                t.Fatalf("ParseAmount(%q) error = %v, wantErr %v", tc.input, err, tc.wantErr)
            }
            if !tc.wantErr && got != tc.want {
                t.Errorf("ParseAmount(%q) = %v, want %v", tc.input, got, tc.want)
            }
        })
    }
}
```

## Subtests

Use `t.Run` for all logically grouped cases. Subtests:

- Run independently with `go test -run TestFoo/subtest_name`
- Report failures at the correct level
- Allow parallel execution with `t.Parallel()`

## Unit Tests

Unit tests cover a single function or type in isolation:

- Inject dependencies via interfaces or function parameters
- Replace I/O with test doubles — never hit the real database or network
- Focus on behavior: given these inputs, expect these outputs (and errors)
- Cover the happy path, error paths, and meaningful edge cases

## Integration Tests

Integration tests verify that components work correctly together:

- Use real infrastructure when practical (test databases, in-memory servers)
- Tag integration tests with a build tag or use an environment variable flag:
  ```go
  //go:build integration
  func TestUserRepository_Save(t *testing.T) { ... }
  ```
- Or gate them with an env variable:
  ```go
  func TestUserRepository_Save(t *testing.T) {
      if os.Getenv("INTEGRATION") == "" {
          t.Skip("set INTEGRATION=1 to run")
      }
      ...
  }
  ```
- Run integration tests separately from unit tests in CI.

## Test Doubles

Go favors hand-written fakes and mocks over heavy mocking frameworks.

| Double type | When to use |
|---|---|
| Fake | When you need a working in-memory implementation (e.g., fake repository) |
| Stub | When you need to return fixed values for specific calls |
| Spy | When you need to record calls without full behavior |
| Mock (generated) | Only when manual mocks become unsustainable; use `gomock` or `testify/mock` |

Prefer fakes over mocks. A fake `UserRepository` that stores data in a map is more valuable than a mock with brittle call expectations.

Define test doubles in `*_test.go` files or in a `testutil` or `internal/testutil` package — keep them out of production packages.

## Naming

Test function names must be in English and follow the pattern:

```
Test<Subject>_<Scenario>
```

Subtest names use plain English sentences describing the scenario:

```go
t.Run("returns error when email is missing", func(t *testing.T) { ... })
t.Run("creates user with hashed password", func(t *testing.T) { ... })
```

## Test Helpers

Extract repeated setup into helper functions. Use `t.Helper()` so that failures point to the call site:

```go
func requireUser(t *testing.T, repo UserRepository, id string) User {
    t.Helper()
    u, err := repo.FindByID(context.Background(), id)
    if err != nil {
        t.Fatalf("requireUser: %v", err)
    }
    return u
}
```

## Assertions

The standard library's `testing` package is sufficient for most cases. Use `testify/assert` or `testify/require` only if the project already uses them — do not introduce them unilaterally.

Prefer `t.Fatalf` to stop execution immediately when a prerequisite fails.
Prefer `t.Errorf` to continue running and collect multiple failures.

## What to Test

Prioritize:

- Business rules and domain logic
- Error paths and error wrapping
- Boundary conditions (empty slices, zero values, max values)
- Critical integration paths (database queries, HTTP endpoints)
- Regressions — every bug fix should come with a test

Do not test:

- Unexported functions that are implementation details with no observable effect
- The exact internal structure of a response when only the observable fields matter
- Framework behavior that is already tested by the framework's own test suite
- Code generated by tools

## Coverage

Use coverage as a diagnostic tool, not a target. 100% coverage with weak assertions is less valuable than 70% coverage with strong, behavior-focused assertions.

Run coverage locally: `go test -cover ./...`
Generate a visual report: `go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out`

Focus coverage on the packages with the most critical business logic.

## Parallel Tests

Use `t.Parallel()` for tests that are independent and do not share mutable state. This speeds up test suites significantly on multi-core machines.

```go
func TestSomething(t *testing.T) {
    t.Parallel()
    // ...
}
```

Do not use `t.Parallel()` when tests share a database, filesystem, or any mutable external state without isolation.

## Running Tests

```sh
go test ./...                          # all packages
go test ./internal/user/...            # specific package tree
go test -run TestParseAmount ./...     # specific test
go test -race ./...                    # race detector
go test -count=1 ./...                 # disable caching
```

Always run with `-race` in CI. Catch race conditions early.
