---
name: rust-development
description: Guides agents in developing, reviewing, refactoring, and evolving Rust projects with ownership-first thinking, idiomatic error handling, safe abstractions, and minimal design. Activate for any task involving a Rust codebase — new features, bug fixes, tests, code review, or architectural decisions.
---

# Objective

Guide agents to produce correct, safe, idiomatic, and maintainable Rust code that works with the ownership model rather than against it, handles errors explicitly using `Result` and `Option`, and applies the simplest design that solves the real problem.

# Fundamental Principles

- Ownership is the design — work with the borrow checker, not around it
- `Result` and `Option` for all fallible and optional values — no panics in production paths
- Explicit mutability — `mut` should be visible and intentional
- Zero-cost abstractions — prefer traits and generics over runtime polymorphism when it is not needed
- Composition over inheritance — Rust has traits, not class hierarchies
- Safe code by default — `unsafe` requires justification, isolation, and documentation
- Start with the simplest correct implementation; use generics and traits when real reuse justifies them
- The type system is your ally — encode invariants in types, not in documentation

# When to Use

- Implementing new features, modules, or crates in a Rust project
- Fixing bugs or borrow checker issues in Rust code
- Writing or extending Rust tests (unit, integration, doc tests)
- Refactoring Rust code for clarity, correctness, or idiomatic style
- Reviewing Rust code for design problems, safety issues, or performance concerns
- Evaluating the architecture or dependencies (`Cargo.toml`) of a Rust project
- Migrating Rust editions or replacing crate dependencies

# When Not to Use

- The project is in a different systems language (C, C++, Zig) even if it has FFI bindings to Rust
- The task is purely about CI/CD, Docker, or infrastructure with no Rust code changes
- The task is about build scripts (`build.rs`) with no changes to the library or binary logic

# Expected Inputs

- A clear description of the task or problem
- Access to the project source tree, `Cargo.toml`, and `Cargo.lock`
- The Rust edition and minimum supported Rust version (MSRV) if declared
- Existing test structure and test conventions
- Feature flags and conditional compilation in use
- Key dependencies (Tokio, Serde, Axum, Clap, Rayon, etc.)
- Clippy configuration (`.cargo/config.toml`, `clippy.toml`)

# Execution Process

1. Read the full request before taking any action.
2. Inspect the project: `Cargo.toml`, workspace structure, key source files.
3. Identify the Rust edition, MSRV, and key crate dependencies.
4. Locate configuration files: `Cargo.toml`, `clippy.toml`, `.cargo/config.toml`.
5. Identify existing conventions: error types, trait usage, module structure, test style.
6. Find similar existing implementations to align with established patterns.
7. Separate explicit requirements from assumptions.
8. Identify risks, borrow checker challenges, and missing information.
9. Choose the simplest correct design that addresses the actual problem.
10. Formulate a small, verifiable implementation plan.
11. Implement changes — model invariants in types, handle errors explicitly.
12. Add or update unit tests (in-module `#[cfg(test)]`) and integration tests (`tests/`).
13. Run `cargo fmt` on changed files.
14. Run `cargo clippy -- -D warnings` (or the project's clippy configuration).
15. Run `cargo test` for all affected crates.
16. Run `cargo check` to verify the project compiles.
17. Review for soundness, `unsafe` blocks, and edge cases.
18. Review the final diff for unintended changes.
19. Present results using the standard response format.

# Mandatory Rules

- All identifiers (functions, types, traits, variables, modules) must be in English.
- Test function names and doc test descriptions must be in English.
- Never use `unwrap()` or `expect()` in production code paths without a documented invariant that proves the value is always `Some`/`Ok`.
- Never use `panic!` for expected runtime conditions — return `Result::Err` instead.
- Every `unsafe` block must have a comment explaining: what invariant is being maintained, why a safe alternative is insufficient.
- Do not clone values to avoid borrow checker issues without first considering lifetime annotations or restructuring.
- Use `?` for error propagation — do not match and re-wrap errors at every call site without adding context.
- Add context to propagated errors using `.map_err` or error libraries (e.g., `thiserror`, `anyhow`) consistent with the project.
- Do not use generic type parameters unless two or more distinct types will be substituted, or the trait boundary provides a testability benefit.
- Do not create a trait unless multiple implementations exist or testability requires it.
- All modules and functions must be in English.

# Architecture and Organization

See [references/architecture.md](references/architecture.md) for detailed guidance.

Organize by domain or layer. Use modules for encapsulation. Use crates for genuine component boundaries. Do not split into separate crates for a project that does not need independent versioning or compilation units.

# Language Conventions

See [references/conventions.md](references/conventions.md) for detailed Rust conventions.

# Testing Strategy

See [references/testing.md](references/testing.md) for the complete testing approach.

Write unit tests in `#[cfg(test)]` modules within the same file. Write integration tests in `tests/`. Use doc tests to verify examples in documentation.

# Mandatory Validations

Before declaring a task complete, confirm:

- [ ] `cargo check` succeeds with no errors
- [ ] `cargo build` succeeds with no warnings
- [ ] `cargo test` passes for all affected crates
- [ ] `cargo fmt --check` reports no formatting changes (or changes were applied)
- [ ] `cargo clippy -- -D warnings` reports no new warnings
- [ ] No new `unwrap()` or `expect()` in production paths without documented invariants
- [ ] No new `unsafe` blocks without isolation and documentation
- [ ] No hardcoded secrets or credentials

If any validation cannot be executed, declare it explicitly under "Risks and limitations."

# Completion Criteria

A task is complete when:

1. The requested behavior is correctly implemented and compiles without errors or warnings.
2. Existing tests continue to pass.
3. New tests cover the new or changed behavior, including `Err` and `None` paths.
4. Code follows Rust idioms and existing project conventions.
5. Errors are handled explicitly with meaningful context.
6. The diff is minimal and focused.
7. The response format has been provided.

# Response Format

```
## Summary
Brief description of what was done.

## Changed files
- `src/domain/order.rs`: description of change.

## Design decisions
- decision; reason; trade-offs.

## Validation
- Commands executed and results obtained.
  If a command could not be run, state it here.

## Tests
- Tests added or modified.
- Scenarios covered: success, error, edge cases.

## Risks and limitations
- Known risks.
- Validations that could not be executed.
- Items that depend on the external environment.

## Suggested next step
One relevant next step, only when necessary.
```

# Handling Limitations and Failures

- If the environment lacks the Rust toolchain, describe what would be run and why.
- If the request is ambiguous, ask one focused clarifying question before writing code.
- If a design conflicts with project conventions, explain the conflict and recommend consistency.
- If the borrow checker rejects a design, explain the ownership issue clearly and propose an idiomatic alternative — do not resort to `clone` or `unsafe` as the first solution.
- If a dependency must be added, justify the choice and verify it is compatible with the project's MSRV and license.

# Supplementary References

- [references/architecture.md](references/architecture.md)
- [references/conventions.md](references/conventions.md)
- [references/testing.md](references/testing.md)
- [references/security.md](references/security.md)
- [references/guardrails.md](references/guardrails.md)
- [references/examples.md](references/examples.md)
- [tests/scenarios.md](tests/scenarios.md)

# Guardrails

All guardrails in `../shared/guardrails.md` apply to this skill. Rust-specific guardrails are in `references/guardrails.md` and extend the shared ones.

Read both before starting any task. When a rule in `references/guardrails.md` conflicts with the shared guardrails, the shared guardrails take precedence unless the Rust-specific file explicitly states otherwise.

Key Rust guardrail areas: no `.unwrap()` in production paths, no `unsafe` without `// SAFETY:` comment, minimal `unsafe` scope, no `Mutex` across `await`, no clone to avoid borrow checker, `cargo audit` for advisories, parameterized SQL, no shell injection via `Command`, structured tracing via the `tracing` crate, secrets via environment variables.
