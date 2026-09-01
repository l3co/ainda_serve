---
name: elixir-development
description: Guides agents in developing, reviewing, refactoring, and evolving Elixir projects with functional idioms, OTP patterns, explicit error handling, and minimal design. Activate for any task involving an Elixir codebase — new features, bug fixes, tests, GenServers, Phoenix controllers, Ecto schemas, or architectural decisions.
---

# Objective

Guide agents to produce correct, idiomatic, maintainable Elixir code that embraces functional programming, uses OTP patterns appropriately, handles errors explicitly with tagged tuples, and applies the simplest design that solves the real problem without unnecessary process or abstraction proliferation.

# Fundamental Principles

- Functions transform data — no shared mutable state, ever
- Pattern matching is the primary control flow mechanism
- Explicit over implicit — `{:ok, value}` and `{:error, reason}` at every boundary
- OTP exists to isolate and recover from failures — use it when failure isolation is the actual need
- "Let it crash" applies to unexpected errors; expected errors must be handled explicitly
- Processes are not threads — spawn only for concurrency, lifecycle, or isolation, not convenience
- Pipe operator (`|>`) for sequential data transformations; `with` for sequential operations that can fail
- Immutable data structures always — functions return new values
- Protocols and Behaviours for polymorphism — no inheritance
- Start with modules and functions; introduce processes only when you need concurrency or state
- The type system is `@spec` + Dialyzer — encode intent in typespecs

# When to Activate

- Creating or modifying Elixir source files (`.ex`, `.exs`)
- Writing or reviewing ExUnit tests
- Designing GenServers, Supervisors, or OTP application trees
- Working on Phoenix controllers, LiveViews, channels, or plugs
- Writing or reviewing Ecto schemas, changesets, queries, or migrations
- Reviewing Elixir code for idiom violations, OTP misuse, or security issues
- Refactoring Elixir modules or processes

# Behavior Limits

- Do not add processes when a function call is sufficient
- Do not apply OTP patterns mechanically without a fault-isolation or concurrency need
- Do not create GenServers solely to hold state that could be passed as function arguments
- Do not introduce umbrella projects for applications that are not genuinely independent
- Do not add behaviours or protocols without a polymorphism need
- Do not invent Mix task names, library APIs, or configuration keys
- Do not use atoms from user-provided input without validation
- Do not create long `with` chains when a sequence of `case` expressions is clearer

# Execution Process

1. Read existing code to understand current module structure, naming conventions, and OTP tree.
2. Identify the task: new feature, bug fix, refactoring, test, or review.
3. Determine whether the task requires a new process, a new module, or changes within an existing one.
4. Verify whether Ecto, Phoenix, or other framework conventions apply.
5. Implement the minimum required change following existing project conventions.
6. Write or update ExUnit tests covering the new or changed behavior.
7. Ensure all public functions have `@spec` and `@doc` if the module is a public API.
8. Run the tests available in the current environment.
9. Run `mix format` or equivalent if available.
10. Run `mix credo` if available and configured.
11. Review for security issues, error handling gaps, and edge cases.
12. Write the final response describing what changed, what was tested, and what was not.

# Mandatory Validations

- [ ] No atoms created from untrusted user input (`String.to_atom/1`, `:"#{input}"`)
- [ ] No hardcoded secrets, credentials, or tokens
- [ ] All public functions in new modules have `@spec`
- [ ] All external inputs validated via changeset or explicit guards before processing
- [ ] Processes (GenServer, Task, Agent) have a documented termination path
- [ ] Supervisors configured with an appropriate restart strategy
- [ ] Ecto queries use parameterized bindings — no string interpolation into queries
- [ ] Error paths tested, not only happy paths

# Handling Uncertainty

- If the OTP tree structure is unclear, read `Application.start/2` and the Supervisor children before proposing changes.
- If the environment does not permit running Mix tasks or ExUnit, describe what would be executed and why.
- If the request is ambiguous, ask one focused clarifying question before writing code.
- If a requested change conflicts with project conventions, explain the conflict and recommend preserving consistency unless there is a clear technical reason to deviate.
- If a task requires a significant OTP restructuring, propose an incremental plan rather than a full rewrite.
- If a dependency must be added, justify the choice and verify compatibility with the project's Elixir and OTP versions.

# Supplementary References

- [references/architecture.md](references/architecture.md)
- [references/conventions.md](references/conventions.md)
- [references/testing.md](references/testing.md)
- [references/security.md](references/security.md)
- [references/guardrails.md](references/guardrails.md)
- [references/examples.md](references/examples.md)
- [tests/scenarios.md](tests/scenarios.md)

# Guardrails

All guardrails in `../shared/guardrails.md` apply to this skill. Elixir-specific guardrails are in `references/guardrails.md` and extend the shared ones.

Read both before starting any task. When a rule in `references/guardrails.md` conflicts with the shared guardrails, the shared guardrails take precedence unless the Elixir-specific file explicitly states otherwise.

Key Elixir guardrail areas: no atoms from user input, explicit `{:ok, _}/{:error, _}` propagation, no `with` without an `else` clause when errors differ, process lifecycle documented, Ecto parameterized queries, no secrets in `config/config.exs` (use `runtime.exs`), structured logging via `Logger` with metadata, `@spec` on all public API functions.
