# go-development skill

## Purpose

This skill guides programming agents to develop, review, refactor, and evolve Go projects with idiomatic style, explicit error handling, minimal design, and incremental evolution.

It applies idiomatic Go thinking — not Java or Python patterns translated to Go syntax.

## Task Types

This skill applies when an agent must:

- Implement a new feature or package in a Go project
- Fix a bug in Go code
- Write or extend Go tests
- Refactor Go code for clarity, correctness, or testability
- Review Go code for design issues, idiomatic problems, or safety concerns
- Evaluate the architecture or dependencies of a Go project

## How to Use

Load `SKILL.md` at the start of any Go task. The skill defines the execution process, mandatory rules, validation checklist, and response format.

Supplementary files in `references/` and `tests/` provide deeper guidance for architecture, conventions, testing, and validation scenarios.

## Complementary Files

| File | Purpose |
|------|---------|
| [SKILL.md](SKILL.md) | Core skill definition — load this first |
| [references/architecture.md](references/architecture.md) | Architectural guidance and decision criteria |
| [references/conventions.md](references/conventions.md) | Go-specific naming, package, and code conventions |
| [references/testing.md](references/testing.md) | Testing strategy and test organization |
| [references/examples.md](references/examples.md) | Short idiomatic code examples for reference |
| [tests/scenarios.md](tests/scenarios.md) | Validation scenarios to evaluate skill correctness |

## Key Limits

- This skill does not cover non-Go parts of a project (Dockerfiles, CI/CD, SQL migrations, shell scripts).
- It does not force a specific architecture onto every project — it helps choose the right level of complexity.
- It does not replace human review for security-critical or high-impact architectural changes.
- It does not guarantee that validations can run in every environment — gaps must be declared explicitly.

## Examples of Requests That Should Activate This Skill

- "Add an endpoint to the existing HTTP handler in this Go service."
- "Fix the race condition in the worker pool."
- "Write table-driven tests for the `parseConfig` function."
- "Refactor the `user` package to reduce coupling between the repository and the handler."
- "Review the error handling in this Go module."
- "Should we use an interface here or a concrete type?"
- "The goroutine in `worker.go` is leaking — fix it."

## Examples of Requests That Should NOT Activate This Skill

- "Write a Python script to process this CSV."
- "Create a Terraform module for this infrastructure."
- "Review the React component in `src/App.tsx`."
- "Write a Dockerfile for this Go application." (no Go code changes)
- "Set up the GitHub Actions pipeline." (no Go code changes)
