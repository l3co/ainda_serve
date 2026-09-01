# python-development skill

## Purpose

This skill guides programming agents to develop, review, refactor, and evolve Python projects with idiomatic style, type hints, minimal design, and a preference for functions over classes when state is not needed. It emphasizes clarity, explicit error handling, and tests that validate observable behavior.

## Task Types

This skill applies when an agent must:

- Implement new features or modules in a Python project
- Fix bugs in Python code
- Write or extend pytest tests
- Refactor Python code for clarity, testability, or idiomatic correctness
- Review Python code for design problems, type annotation gaps, or security issues
- Evaluate or propose architecture for a Python project
- Migrate Python versions or replace a dependency

## How to Use

Load `SKILL.md` at the start of any Python task. It defines the execution process, mandatory rules, validation checklist, and response format.

Supplementary files in `references/` provide deeper guidance for architecture, conventions, testing, and code examples. `tests/scenarios.md` contains evaluation scenarios.

## Complementary Files

| File | Purpose |
|------|---------|
| [SKILL.md](SKILL.md) | Core skill definition — load this first |
| [references/architecture.md](references/architecture.md) | Architectural guidance and decision criteria |
| [references/conventions.md](references/conventions.md) | Python-specific naming, module, and code conventions |
| [references/testing.md](references/testing.md) | Testing strategy with pytest, fixtures, and mocking |
| [references/examples.md](references/examples.md) | Short idiomatic Python code examples for reference |
| [tests/scenarios.md](tests/scenarios.md) | Validation scenarios to evaluate skill correctness |

## Key Limits

- This skill does not cover non-Python files in a project (SQL, YAML, Dockerfiles).
- It does not force Django, FastAPI, or any specific framework — it adapts to what the project uses.
- It does not replace human review for security-critical changes or data processing pipelines.
- It does not guarantee test execution in every environment — gaps must be declared explicitly.

## Examples of Requests That Should Activate This Skill

- "Add an endpoint to this FastAPI service."
- "Fix the KeyError in `config_loader.py`."
- "Write pytest tests for the `calculate_discount` function."
- "Refactor this module to use type hints."
- "Should we use a dataclass or a TypedDict here?"
- "Review the exception handling in this Django view."
- "Migrate this codebase from Python 3.9 to Python 3.12."

## Examples of Requests That Should NOT Activate This Skill

- "Write a Rust function for this parsing task."
- "Create a Terraform module for the deployment."
- "Review the React component in `src/App.tsx`."
- "Set up the Dockerfile." (no Python code changes)
- "Write a SQL migration for this schema change."
