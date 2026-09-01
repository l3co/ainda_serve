# java-development skill

## Purpose

This skill guides programming agents to develop, review, refactor, and evolve Java projects with idiomatic OOP, pragmatic SOLID design, modern Java language features, and minimal complexity. It emphasizes composability, clear exception strategies, and tests that validate observable behavior.

## Task Types

This skill applies when an agent must:

- Implement new features or classes in a Java project
- Fix bugs in Java code
- Write or extend JUnit tests
- Refactor Java code for clarity, testability, or better use of language features
- Review Java code for design problems, idiomatic issues, or security vulnerabilities
- Evaluate or propose architecture for a Java project
- Migrate Java version or replace a framework dependency

## How to Use

Load `SKILL.md` at the start of any Java task. The skill defines the execution process, mandatory rules, validation checklist, and response format.

Supplementary files in `references/` provide deeper guidance for architecture, conventions, testing, and code examples. `tests/scenarios.md` contains evaluation scenarios for validating the skill.

## Complementary Files

| File | Purpose |
|------|---------|
| [SKILL.md](SKILL.md) | Core skill definition — load this first |
| [references/architecture.md](references/architecture.md) | Architectural guidance and decision criteria |
| [references/conventions.md](references/conventions.md) | Java-specific naming, package, and code conventions |
| [references/testing.md](references/testing.md) | Testing strategy with JUnit 5, Mockito, and AssertJ |
| [references/examples.md](references/examples.md) | Short idiomatic Java code examples for reference |
| [tests/scenarios.md](tests/scenarios.md) | Validation scenarios to evaluate skill correctness |

## Key Limits

- This skill does not cover non-Java files in a project (SQL, YAML, Dockerfiles, CI pipelines).
- It does not force DDD, Clean Architecture, or Spring onto every project — it guides the choice.
- It does not replace human review for security-critical or high-impact architectural changes.
- It does not guarantee test execution in every environment — gaps must be declared explicitly.

## Examples of Requests That Should Activate This Skill

- "Add a new REST endpoint to this Spring Boot service."
- "Fix the `NullPointerException` in `OrderService.process`."
- "Write JUnit tests for the `InvoiceCalculator` class."
- "Refactor this service to remove the circular dependency."
- "Should we use a record or a class for this DTO?"
- "Review the exception handling in this module."
- "Migrate this code from Java 11 to Java 21."

## Examples of Requests That Should NOT Activate This Skill

- "Write a Kotlin coroutine for this async operation."
- "Create a Terraform module for this deployment."
- "Review the React component in `src/App.tsx`."
- "Set up the Dockerfile for this Java app." (no Java code changes)
- "Write a Python script to process this data."
