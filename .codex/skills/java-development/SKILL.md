---
name: java-development
description: Guides agents in developing, reviewing, refactoring, and evolving Java projects with idiomatic OOP, pragmatic SOLID principles, modern Java features, and minimal design. Activate for any task involving a Java codebase — new features, bug fixes, tests, code review, or architectural decisions.
---

# Objective

Guide agents to produce correct, idiomatic, maintainable Java code that respects existing project conventions, uses modern Java features appropriately, and applies object-oriented design pragmatically without imposing unnecessary complexity.

# Fundamental Principles

- Object-oriented design driven by behavior, not structure
- Immutability by default for value objects and data carriers
- Composition over inheritance — inheritance only for genuine is-a relationships
- Interfaces define contracts; classes fulfill them
- Checked exceptions for recoverable conditions; unchecked for programmer errors
- Modern Java features (records, sealed classes, pattern matching, streams) when they improve clarity
- Minimal abstractions — add layers only when real complexity justifies them
- SOLID principles applied pragmatically, not mechanically

# When to Use

- Implementing new features or classes in a Java project
- Fixing bugs in Java code
- Writing or extending JUnit tests
- Refactoring Java code for clarity, testability, or correct use of language features
- Reviewing Java code for design problems, idiomatic issues, or security concerns
- Evaluating the architecture or dependencies of a Java project
- Migrating between Java versions or frameworks

# When Not to Use

- The project is primarily in another JVM language (Kotlin, Scala, Groovy) even if it has some Java files
- The task is purely about build pipelines, Kubernetes configs, or infrastructure with no Java code changes
- The task is about a different JVM language's idioms

# Expected Inputs

- A clear description of the task or problem
- Access to the project source tree and build file (`pom.xml` or `build.gradle`)
- The Java version declared in the build file or toolchain configuration
- Existing test files and frameworks in use (JUnit 4 or 5, Mockito, AssertJ, etc.)
- Frameworks in use (Spring Boot, Quarkus, Micronaut, Jakarta EE, etc.)
- Lint and code style configuration (Checkstyle, SpotBugs, PMD, ErrorProne, etc.)

# Execution Process

1. Read the full request before taking any action.
2. Inspect the project structure: directory layout, packages, build file.
3. Identify the Java version, build tool (Maven or Gradle), and key dependencies.
4. Locate configuration files: `pom.xml` or `build.gradle`, application config, lint config.
5. Identify existing conventions: package naming, exception strategy, annotation use, test style.
6. Find similar existing implementations to align with established patterns.
7. Separate explicit requirements from assumptions.
8. Identify risks, ambiguities, and missing information.
9. Choose the simplest correct solution that addresses the actual problem.
10. Formulate a small, verifiable implementation plan.
11. Implement changes with focus and cohesion.
12. Add or update JUnit tests with meaningful assertions.
13. Run the build tool's test command (`mvn test` or `gradle test`).
14. Run linters and static analysis tools if configured.
15. Review for security, exception handling gaps, and edge cases.
16. Review the final diff for unintended changes.
17. Present results using the standard response format.

# Mandatory Rules

- Classes, methods, interfaces, fields, and variables must be in English.
- Test method names and test descriptions must be in English.
- Never swallow exceptions: no empty catch blocks without a documented reason.
- Never catch `Exception` or `Throwable` at a low level unless you can handle them meaningfully.
- Use specific exception types — not `RuntimeException` with a message string as the only distinction.
- Prefer immutable objects for value types and data transfer objects.
- Use `Optional<T>` as a return type for methods that may return no value — not as a field type or parameter type.
- Close resources with try-with-resources — never rely on manual `finally` for closeable resources.
- Do not add `Manager`, `Helper`, `Util`, or `Processor` to class names unless those words genuinely describe the responsibility.
- Do not create service classes that only delegate method calls to another service without adding behavior.
- Do not create deep inheritance hierarchies — prefer composition.
- Dependency injection should flow from the outside in — do not instantiate dependencies inside classes.

# Architecture and Organization

See [references/architecture.md](references/architecture.md) for detailed guidance.

Organize packages by domain concern. Apply SOLID pragmatically. Use DDD concepts when the domain is complex enough to justify them.

# Language Conventions

See [references/conventions.md](references/conventions.md) for detailed Java conventions.

# Testing Strategy

See [references/testing.md](references/testing.md) for the complete testing approach.

Use JUnit 5 with clear, behavior-focused test methods. Mock external dependencies with Mockito or equivalent, but prefer real implementations for simple collaborators.

# Mandatory Validations

Before declaring a task complete, confirm:

- [ ] `mvn compile` or `gradle compileJava` succeeds without warnings
- [ ] `mvn test` or `gradle test` passes for all affected modules
- [ ] No new static analysis warnings (if configured)
- [ ] No unclosed resources or swallowed exceptions introduced
- [ ] No hardcoded secrets or credentials in code or test fixtures
- [ ] No `System.out.println` left in production code
- [ ] All new public API has appropriate visibility modifiers

If any validation cannot be executed, declare it explicitly under "Risks and limitations."

# Completion Criteria

A task is complete when:

1. The requested behavior is correctly implemented and verified.
2. Existing tests continue to pass.
3. New tests cover the new or changed behavior, including exception paths.
4. Code follows Java idioms and existing project conventions.
5. Exceptions are handled at the appropriate level with meaningful messages.
6. The diff is minimal and focused.
7. The response format has been provided.

# Response Format

```
## Summary
Brief description of what was done.

## Changed files
- `path/to/File.java`: description of change.

## Design decisions
- decision; reason; trade-offs.

## Validation
- Commands executed and results obtained.
  If a command could not be run, state it here.

## Tests
- Tests added or modified.
- Scenarios covered, including exception and edge cases.

## Risks and limitations
- Known risks.
- Validations that could not be executed.
- Items that depend on the external environment.

## Suggested next step
One relevant next step, only when necessary.
```

# Handling Limitations and Failures

- If the environment lacks the build tool or JDK, describe what would be run and why.
- If the request is ambiguous, ask one focused clarifying question before writing code.
- If a requested change conflicts with project conventions, explain the conflict and recommend preserving consistency unless there is a clear technical reason to deviate.
- If a task requires a significant architectural change, propose an incremental plan.
- If a dependency must be added, justify the choice and verify it is compatible with the project's Java version and license requirements.

# Supplementary References

- [references/architecture.md](references/architecture.md)
- [references/conventions.md](references/conventions.md)
- [references/testing.md](references/testing.md)
- [references/security.md](references/security.md)
- [references/guardrails.md](references/guardrails.md)
- [references/examples.md](references/examples.md)
- [tests/scenarios.md](tests/scenarios.md)

# Guardrails

All guardrails in `../shared/guardrails.md` apply to this skill. Java-specific guardrails are in `references/guardrails.md` and extend the shared ones.

Read both before starting any task. When a rule in `references/guardrails.md` conflicts with the shared guardrails, the shared guardrails take precedence unless the Java-specific file explicitly states otherwise.

Key Java guardrail areas: no empty catch blocks, constructor injection only (no `@Autowired` fields), no `Optional` as parameters, parameterized JPA/SQL queries, no `ObjectInputStream` on untrusted data, test slices over full `@SpringBootTest`, structured logging via SLF4J with MDC, secrets via externalized configuration.
