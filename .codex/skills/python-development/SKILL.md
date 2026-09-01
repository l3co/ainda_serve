---
name: python-development
description: Guides agents in developing, reviewing, refactoring, and evolving Python projects with idiomatic style, type hints, and a preference for simplicity over structural ceremony. Activate for any task involving a Python codebase — new features, bug fixes, tests, code review, or architectural decisions.
---

# Objective

Guide agents to produce correct, idiomatic, maintainable Python code that respects existing project conventions, uses type hints effectively, and applies the simplest design that solves the real problem.

# Fundamental Principles

- Readability over cleverness — code is read far more often than it is written
- Functions over classes when no persistent state is needed
- Explicit over implicit — no hidden side effects, no magic
- Type hints as a communication and verification tool, not a bureaucratic requirement
- Prefer the standard library before reaching for third-party packages
- Fail loudly and early — never swallow exceptions silently
- Minimal design first; add abstraction only when real complexity justifies it
- Respect PEP 8 and the style choices already established in the project

# When to Use

- Implementing new features or modules in a Python project
- Fixing bugs in Python code
- Writing or extending pytest tests
- Refactoring Python code for clarity, testability, or idiomatic correctness
- Reviewing Python code for design problems, type annotation gaps, or security issues
- Evaluating the architecture or dependencies of a Python project
- Migrating Python versions or replacing dependencies

# When Not to Use

- The project is in a different language, even if it runs Python scripts as tooling
- The task is purely about infrastructure, CI/CD, Docker, or system configuration with no Python code changes
- The codebase uses a language that runs on the Python VM but is not Python (Cython pure-C, Jython, etc.)

# Expected Inputs

- A clear description of the task or problem
- Access to the project source tree and configuration (`pyproject.toml`, `setup.cfg`, `requirements.txt`)
- The Python version declared in the project configuration or runtime
- Existing test files and testing frameworks in use (pytest, unittest, etc.)
- Frameworks in use (FastAPI, Django, Flask, SQLAlchemy, Pydantic, etc.)
- Lint, format, and type-check configuration (Ruff, Black, Flake8, mypy, pyright, etc.)

# Execution Process

1. Read the full request before taking any action.
2. Inspect the project structure: directories, modules, `pyproject.toml` or equivalent.
3. Identify the Python version, virtual environment, and key dependencies.
4. Locate configuration files: `pyproject.toml`, `setup.cfg`, lint config, mypy/pyright config.
5. Identify existing conventions: naming, type annotation style, class vs. function preference, test style.
6. Find similar existing implementations to align with established patterns.
7. Separate explicit requirements from assumptions.
8. Identify risks, ambiguities, and missing information.
9. Choose the simplest correct solution that addresses the actual problem.
10. Formulate a small, verifiable implementation plan.
11. Implement changes with focus and cohesion.
12. Add or update pytest tests covering the new behavior and error paths.
13. Run the formatter configured in the project (Black, Ruff format, etc.).
14. Run the linter configured in the project (Ruff, Flake8, etc.).
15. Run the type checker if configured (mypy, pyright).
16. Run `pytest` for the relevant modules.
17. Review for security issues, exception handling gaps, and edge cases.
18. Review the final diff for unintended changes.
19. Present results using the standard response format.

# Mandatory Rules

- All identifiers (functions, classes, variables, modules) must be in English.
- Test function names and fixture names must be in English.
- Never write a bare `except:` or `except Exception:` without a documented reason.
- Never swallow exceptions silently — always log, re-raise, or handle meaningfully.
- Do not use mutable default arguments: `def f(items=[])` is a bug.
- Do not rely on import-time side effects — keep module bodies free of observable side effects.
- Use type hints for all function signatures in new or modified code.
- Use `dataclass` or `TypedDict` instead of plain dicts for structured data.
- Do not name modules or packages `utils`, `helpers`, or `common` — name them after what they provide.
- Do not add a class when a function is sufficient — use classes for state, behavior, and identity, not for namespace grouping.
- Do not expose internal implementation details through the public module interface.

# Architecture and Organization

See [references/architecture.md](references/architecture.md) for detailed guidance.

Organize by domain concern. Prefer functions for stateless logic. Use classes for types with state, identity, or invariants. Apply dependency injection via function parameters or constructor arguments — not via module-level singletons.

# Language Conventions

See [references/conventions.md](references/conventions.md) for detailed Python conventions.

# Testing Strategy

See [references/testing.md](references/testing.md) for the complete testing approach.

Use pytest with clear, behavior-focused test functions. Prefer fixtures for test data. Mock only external I/O — not logic you own.

# Mandatory Validations

Before declaring a task complete, confirm:

- [ ] `python -m py_compile` or the build tool succeeds for changed files
- [ ] `pytest` passes for all affected modules
- [ ] The formatter reports no changes (or changes were applied)
- [ ] The linter reports no new errors
- [ ] The type checker reports no new errors (if configured)
- [ ] No mutable default arguments introduced
- [ ] No bare `except:` introduced
- [ ] No hardcoded secrets or credentials

If any validation cannot be executed, declare it explicitly under "Risks and limitations."

# Completion Criteria

A task is complete when:

1. The requested behavior is correctly implemented and verified.
2. Existing tests continue to pass.
3. New tests cover the new or changed behavior, including error paths.
4. Code follows Python idioms and existing project conventions.
5. Type hints are present for all new or modified function signatures.
6. The diff is minimal and focused.
7. The response format has been provided.

# Response Format

```
## Summary
Brief description of what was done.

## Changed files
- `path/to/module.py`: description of change.

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

- If the environment lacks the Python runtime or tools, describe what would be executed and why.
- If the request is ambiguous, ask one focused clarifying question before writing code.
- If a requested change conflicts with project conventions, explain the conflict and recommend preserving consistency unless there is a clear technical reason to deviate.
- If a task requires a significant architectural change, propose an incremental plan.
- If a dependency must be added, justify the choice and confirm it is compatible with the project's Python version and license.

# Supplementary References

- [references/architecture.md](references/architecture.md)
- [references/conventions.md](references/conventions.md)
- [references/testing.md](references/testing.md)
- [references/security.md](references/security.md)
- [references/guardrails.md](references/guardrails.md)
- [references/examples.md](references/examples.md)
- [tests/scenarios.md](tests/scenarios.md)

# Guardrails

All guardrails in `../shared/guardrails.md` apply to this skill. Python-specific guardrails are in `references/guardrails.md` and extend the shared ones.

Read both before starting any task. When a rule in `references/guardrails.md` conflicts with the shared guardrails, the shared guardrails take precedence unless the Python-specific file explicitly states otherwise.

Key Python guardrail areas: no bare `except:`, no mutable default arguments, type hints on all public signatures, no wildcard imports, parameterized SQL (no f-strings in queries), no `eval`/`exec` on user input, no `pickle.loads` on untrusted data, structured logging via `structlog`, secrets via environment variables.
