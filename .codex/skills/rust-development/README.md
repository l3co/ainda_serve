# rust-development skill

## Purpose

This skill guides programming agents to develop, review, refactor, and evolve Rust projects with ownership-first thinking, idiomatic error handling via `Result` and `Option`, safe abstractions, and minimal design. It works with the borrow checker and type system rather than around them.

## Task Types

This skill applies when an agent must:

- Implement new features, modules, or crates in a Rust project
- Fix borrow checker errors, lifetime issues, or incorrect error handling
- Write or extend Rust unit, integration, or doc tests
- Refactor Rust code for clarity, correctness, or idiomatic style
- Review Rust code for safety issues, incorrect `unsafe` usage, or design problems
- Evaluate the architecture or crate dependencies of a Rust project
- Migrate Rust editions, update MSRV, or replace a crate dependency

## How to Use

Load `SKILL.md` at the start of any Rust task. It defines the execution process, mandatory rules, validation checklist, and response format.

Supplementary files in `references/` provide deeper guidance for architecture, conventions, testing, and code examples. `tests/scenarios.md` contains evaluation scenarios.

## Complementary Files

| File | Purpose |
|------|---------|
| [SKILL.md](SKILL.md) | Core skill definition — load this first |
| [references/architecture.md](references/architecture.md) | Crate and module organization guidance |
| [references/conventions.md](references/conventions.md) | Rust-specific naming, trait, and error handling conventions |
| [references/testing.md](references/testing.md) | Testing strategy with cargo test, integration tests, and doc tests |
| [references/examples.md](references/examples.md) | Short idiomatic Rust code examples for reference |
| [tests/scenarios.md](tests/scenarios.md) | Validation scenarios to evaluate skill correctness |

## Key Limits

- This skill does not cover C/C++ FFI or `cbindgen`/`bindgen` details beyond the Rust side.
- It does not force async runtime choices — it adapts to what the project uses (Tokio, async-std, etc.).
- It does not replace human review for safety-critical `unsafe` code or cryptographic implementations.
- It does not guarantee test execution in every environment — gaps must be declared explicitly.

## Examples of Requests That Should Activate This Skill

- "Add a new command to this Clap CLI application."
- "Fix the lifetime error in the parser module."
- "Write tests for the `calculate_checksum` function."
- "Refactor this module to reduce cloning."
- "Why does the borrow checker reject this pattern?"
- "Add async support to this HTTP handler using Axum."
- "Review the `unsafe` block in `src/ffi.rs`."

## Examples of Requests That Should NOT Activate This Skill

- "Write a Python script to parse this config file."
- "Create the Kubernetes deployment for this service."
- "Review the Go service that calls this Rust binary."
- "Write the C wrapper for this Rust function." (C side, not Rust side)
- "Set up the CI pipeline for this project." (no Rust code changes)
