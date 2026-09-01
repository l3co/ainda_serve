---
name: go-development
description: Guides agents in developing, reviewing, refactoring, and evolving Go projects with idiomatic conventions, explicit error handling, and minimal design. Activate for any task involving a Go codebase — new features, bug fixes, tests, code review, or refactoring.
---

# Objective

Guide agents to produce correct, idiomatic, minimal, and maintainable Go code that respects existing project conventions and solves the actual problem at hand without introducing unnecessary complexity.

# Fundamental Principles

- Explicit over implicit
- Simplicity over cleverness
- Composition over inheritance
- Errors are values — handle them explicitly at the right level
- Interfaces are satisfied implicitly — define them near their consumers
- Concurrency is a design concern — use it only when genuinely required
- The zero value should be useful when possible
- Start small; evolve only when real complexity justifies it

# When to Use

- Creating new features or packages in a Go project
- Fixing bugs in Go code
- Writing or extending tests for Go packages
- Refactoring Go code for clarity, correctness, or performance
- Reviewing Go code for idiomatic style and design problems
- Analyzing the architecture of a Go project
- Evaluating or migrating Go dependencies

# When Not to Use

- The project is primarily in another language, even if it contains Go scripts or tools
- The task is purely about infrastructure, CI/CD, deployment configuration, or container setup with no Go code changes
- The codebase is a different language that happens to call Go binaries

# Expected Inputs

- A clear description of the task or problem
- Access to the project source tree (files, directories, `go.mod`, `go.sum`)
- The Go version declared in `go.mod` or available in the environment
- Existing test files and test conventions
- Project-specific lint and format configuration (`.golangci.yml`, `Makefile`, etc.)

# Execution Process

1. Read the full request before taking any action.
2. Inspect the project structure: directories, packages, `go.mod`, notable files.
3. Identify the Go version, module path, and key dependencies.
4. Locate configuration files: `go.mod`, `go.sum`, Makefile, linter config.
5. Identify existing conventions: naming, error wrapping style, package structure, test style.
6. Find similar existing implementations to align with established patterns.
7. Separate explicit requirements from assumptions.
8. Identify risks, ambiguities, and missing information.
9. Choose the simplest correct solution that addresses the actual problem.
10. Formulate a small, verifiable plan before writing code.
11. Implement changes with focus and cohesion.
12. Add or update tests using table-driven patterns with subtests.
13. Run `go fmt` or `goimports` on changed files.
14. Run `go vet ./...` on affected packages.
15. Run `go test ./...` or the relevant packages.
16. Review for security issues, error handling gaps, and edge cases.
17. Review the final diff for unintended changes.
18. Present results using the standard response format.

# Mandatory Rules

- Always handle returned errors — never discard with `_` without explicit, documented justification.
- Never use `panic` for expected or recoverable errors.
- Never introduce global mutable state without a clear reason documented in code.
- Define interfaces in the consuming package, not the providing package.
- Keep interfaces small — one or two methods is almost always sufficient.
- Use `context.Context` as the first parameter of any function that may block, do I/O, or need cancellation.
- Every goroutine must have a defined lifecycle and a clear termination path.
- Prevent goroutine leaks — use `sync.WaitGroup`, channels with proper draining, or context cancellation.
- Prefer synchronous code unless concurrency provides a concrete, measurable benefit.
- Wrap errors with context using `fmt.Errorf("operation description: %w", err)`.
- Do not wrap the same error multiple times without adding new context at each level.
- All identifiers in code (functions, types, variables, constants, fields) must be in English.
- Test function names and subtest names must be in English.
- Do not create packages named `utils`, `helpers`, or `common` — name them after what they provide.

# Architecture and Organization

See [references/architecture.md](references/architecture.md) for detailed guidance.

Prefer flat package structures for small and medium projects. Group by domain concern when the project is large enough to justify it. Avoid circular imports — Go enforces this, but also avoid designs that strain against it.

# Language Conventions

See [references/conventions.md](references/conventions.md) for detailed Go-specific conventions.

# Testing Strategy

See [references/testing.md](references/testing.md) for the complete testing approach.

Use table-driven tests with `t.Run` subtests. Test observable behavior, not internal implementation.

# Mandatory Validations

Before declaring a task complete, confirm:

- [ ] `go build ./...` succeeds without errors
- [ ] `go vet ./...` produces no new warnings
- [ ] `go test ./...` passes for all affected packages
- [ ] `gofmt -l .` or `goimports` shows no unformatted files
- [ ] No goroutine leaks are introduced
- [ ] No new unchecked error returns
- [ ] No hardcoded secrets, credentials, or tokens
- [ ] Security checklist in [references/security.md](references/security.md) reviewed for changed code

If any validation cannot be executed in the current environment, declare it explicitly under "Risks and limitations."

# Completion Criteria

A task is complete when:

1. The requested behavior is correctly implemented and verified.
2. Existing tests continue to pass.
3. New tests cover the new or changed behavior, including error paths.
4. Code follows Go idioms and existing project conventions.
5. All errors are handled explicitly and with appropriate context.
6. The diff is minimal, focused, and free of unintended changes.
7. The response format has been filled out completely.

# Response Format

```
## Summary
Brief description of what was done.

## Changed files
- `path/to/file.go`: description of change.

## Design decisions
- decision; reason; trade-offs.

## Validation
- Commands executed and results obtained.
  If a command could not be run, state it here.

## Tests
- Tests added or modified.
- Scenarios covered, including error and edge cases.

## Risks and limitations
- Known risks.
- Validations that could not be executed.
- Items that depend on the external environment.

## Suggested next step
One relevant next step, only when necessary.
```

# Handling Limitations and Failures

- If the environment does not permit running tests or the Go toolchain, describe what would be executed and why.
- If the request is ambiguous or incomplete, ask one focused question before writing code.
- If a requested change conflicts with established project conventions, explain the conflict, evaluate the impact, and recommend preserving consistency unless there is a clear technical reason to deviate.
- If a task requires a complex architectural change, propose a staged incremental plan instead of a full rewrite.
- If a dependency must be added or removed, justify the decision explicitly.

# Supplementary References

- [references/architecture.md](references/architecture.md)
- [references/conventions.md](references/conventions.md)
- [references/testing.md](references/testing.md)
- [references/security.md](references/security.md)
- [references/guardrails.md](references/guardrails.md)
- [references/examples.md](references/examples.md)
- [tests/scenarios.md](tests/scenarios.md)

# Guardrails

All guardrails in `../shared/guardrails.md` apply to this skill. Go-specific guardrails are in `references/guardrails.md` and extend the shared ones.

Read both before starting any task. When a rule in `references/guardrails.md` conflicts with the shared guardrails, the shared guardrails take precedence unless the Go-specific file explicitly states otherwise.

Key Go guardrail areas: error handling (no discarded errors, no panic for recoverable conditions), goroutine lifecycle documentation, interfaces at the consumer, no global mutable state for DI, parameterized SQL, no shell injection, structured logging via `slog`, secrets via environment variables.
