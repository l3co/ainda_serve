# Java Skill Validation Scenarios

A matrix of scenarios to evaluate whether this skill correctly guides an agent working on Java projects.

## Scoring Rubric

Each scenario is evaluated on a 0–3 scale:

| Score | Meaning |
|---|---|
| **3 — Pass** | All expected behaviors exhibited; no behaviors to avoid were observed; all approval criteria met |
| **2 — Partial** | Most expected behaviors exhibited; one or two approval criteria missed; no critical behaviors to avoid |
| **1 — Marginal** | Core intent partially satisfied; important behaviors missed; at least one behavior to avoid was observed |
| **0 — Fail** | Expected behavior was not exhibited; a behavior to avoid was clearly observed; or the task was refused without justification |

A skill is considered **correctly calibrated** for a scenario when it consistently scores 3. A score of 1 or below in more than two scenarios indicates the skill needs revision.

**Evaluation method**: Present the scenario input to the agent with the skill loaded. Compare the agent's response against the expected behavior, behavior to avoid, and approval criteria. Assign a score.

---

## Scenario 1: Small Feature Creation

**Context**: A Spring Boot REST API managing products. Filtering by category is not yet implemented.

**Input**: "Add filtering by category to the `GET /products` endpoint."

**Expected skill behavior**:
- Reads the existing `ProductController`, `ProductService`, and `ProductRepository`
- Identifies the existing query method convention (Spring Data JPA `findAll(Specification<T> spec)` or a named query)
- Adds a `category` request parameter with a default of "no filter"
- Adds or extends a repository method
- Writes a unit test for the service logic and an integration test for the repository query
- Does not introduce a specification framework if one is not already present

**Behavior to avoid**:
- Adding a generic `SpecificationBuilder` abstraction before confirming two or more filter criteria
- Changing unrelated controller methods

**Approval criteria**:
- `GET /products?category=books` returns only products in that category
- `GET /products` without parameter returns all products
- Tests cover both cases and the "not found" edge case

---

## Scenario 2: Bug Fix

**Context**: An `InvoiceService` throws a `NullPointerException` when a customer has no address.

**Input**: "Fix the NPE in `InvoiceService.generate` when the customer address is null."

**Expected skill behavior**:
- Reads `InvoiceService.generate` to locate the null dereference
- Determines whether address being null is a valid business state or a programming error
- If valid: adds a null check and returns an appropriate error or default
- If a programming error: adds a precondition check with a clear message
- Writes a test reproducing the NPE scenario and verifying the fix

**Behavior to avoid**:
- Wrapping the entire method in a try-catch to suppress all exceptions
- Returning `null` from the method as the "fix"

**Approval criteria**:
- The NPE is eliminated
- The fix handles the null case explicitly
- A test verifies the behavior with a null address

---

## Scenario 3: Legacy Refactoring

**Context**: A `CustomerManager.java` class with 1200 lines mixing HTTP logic, business rules, database access, and email sending.

**Input**: "Refactor `CustomerManager` to make it maintainable."

**Expected skill behavior**:
- Reads the file and maps responsibilities
- Proposes an incremental plan: extract one responsibility at a time (e.g., email sending first, then persistence)
- Extracts collaborators as interfaces to preserve testability
- Does not rewrite business logic while restructuring
- Ensures all existing tests continue to pass after each extraction step

**Behavior to avoid**:
- Rewriting all 1200 lines in one pass
- Introducing microservices or event sourcing to solve a single-class problem
- Breaking callers without updating them

**Approval criteria**:
- All existing tests pass
- Each extracted class has a single responsibility
- The refactoring is delivered in reviewable increments

---

## Scenario 4: Writing Tests

**Context**: A `DiscountCalculator` class applies percentage discounts to order subtotals. It has no tests.

**Input**: "Write JUnit 5 tests for `DiscountCalculator`."

**Expected skill behavior**:
- Reads the class to understand the contract
- Writes parameterized tests for multiple discount rates and subtotals
- Covers: standard discount, zero discount, 100% discount, negative subtotal (error case), discount exceeding subtotal
- Uses only the public API
- Names tests expressively in English

**Behavior to avoid**:
- Testing private helper methods via reflection
- Using Mockito to mock pure arithmetic logic
- Writing one large test method with many unrelated assertions

**Approval criteria**:
- `mvn test` passes
- All meaningful cases have a named test or parameter
- Test names follow the `shouldDoX_whenY` or `returnsXWhenY` convention

---

## Scenario 5: Architecture Analysis

**Context**: A Java monolith handles orders, customers, inventory, and shipping in a single Spring Boot application with no package separation.

**Input**: "How should we organize this codebase?"

**Expected skill behavior**:
- Reads the existing code to understand actual domain boundaries
- Identifies which domains are present and how they interact
- Proposes package-by-feature organization as an initial, low-risk improvement
- Discusses when/whether a modular monolith or separate services are justified
- Provides an incremental migration path

**Behavior to avoid**:
- Immediately recommending microservices
- Recommending DDD with aggregates and domain events for a project that may not need them yet
- Providing a generic answer without reading the actual code

**Approval criteria**:
- The recommendation is proportionate to the observed complexity
- Trade-offs between approaches are explained
- A concrete first step is provided

---

## Scenario 6: Project Without Tests

**Context**: A Java library for parsing configuration files. No test files exist.

**Input**: "Add tests to this library."

**Expected skill behavior**:
- Reads the library's public API
- Adds JUnit 5 tests starting with the most critical parsing logic
- Covers: valid input, invalid input, edge cases (empty file, unknown key)
- Documents which areas were not covered and why

**Behavior to avoid**:
- Adding Mockito to mock the file parsing logic itself
- Writing tests only for trivial accessor methods
- Targeting a specific coverage percentage rather than critical paths

**Approval criteria**:
- `mvn test` passes
- Critical parsing paths are covered
- Gaps are documented

---

## Scenario 7: Project With Existing Conventions

**Context**: A Java project uses a custom `Result<T, E>` type instead of exceptions for domain errors.

**Input**: "Add email uniqueness validation to the user registration flow."

**Expected skill behavior**:
- Reads how existing validations return `Result.failure(...)` instead of throwing exceptions
- Implements email uniqueness validation returning `Result.failure(new DuplicateEmailError(email))` on conflict
- Does not introduce a thrown exception for a domain validation in a project that uses `Result`

**Behavior to avoid**:
- Throwing `IllegalArgumentException` or a custom exception when the project uses `Result`
- Introducing a different error representation pattern

**Approval criteria**:
- The new validation is consistent with existing ones
- Tests verify both the success case and the duplicate email failure case

---

## Scenario 8: Unnecessary Complexity Request

**Context**: A simple Java utility that formats names.

**Input**: "Use the Strategy pattern to support different name formatting styles."

**Expected skill behavior**:
- Questions whether multiple strategies genuinely exist or are forthcoming
- If only one format is needed, implements a simple method
- If multiple formats are confirmed, introduces a `NameFormatter` interface with concrete implementations — not a factory, registry, and builder

**Behavior to avoid**:
- Implementing a full Strategy + Factory + Registry pattern for one format
- Accepting the complexity without questioning the actual requirement

**Approval criteria**:
- The agent challenges the premise when only one format exists
- If multiple formats are confirmed, the implementation is proportionate (interface + two or three implementations)

---

## Scenario 9: Incomplete Requirements

**Context**: A Java e-commerce service.

**Input**: "Add loyalty points to orders."

**Expected skill behavior**:
- Identifies missing information: How are points calculated? When are they awarded (at order creation or payment)? Where are they stored? Is there an expiry?
- Asks one focused clarifying question covering the most critical unknown

**Behavior to avoid**:
- Building a full loyalty system based on guessed requirements
- Refusing to engage at all

**Approval criteria**:
- At least one focused question is asked before writing code
- The question identifies the most critical missing business rule

---

## Scenario 10: Dependency Change

**Context**: A Java service uses Apache HttpClient 4. The team wants to migrate to the Java 11+ built-in `HttpClient`.

**Input**: "Replace Apache HttpClient 4 with the built-in Java HttpClient."

**Expected skill behavior**:
- Lists all usages of Apache HttpClient in the codebase
- Maps the API differences (blocking vs. async, request building, response handling)
- Migrates one HTTP call at a time
- Updates `pom.xml` to remove the Apache dependency after all usages are replaced
- Ensures tests pass after each step

**Behavior to avoid**:
- Replacing all usages in one commit without running tests between steps
- Silently changing error handling behavior (Apache throws `IOException`; the built-in client may behave differently)

**Approval criteria**:
- All tests pass
- `pom.xml` no longer declares Apache HttpClient as a dependency
- HTTP behavior is unchanged from the caller's perspective

---

## Scenario 11: Small Project — DDD Not Needed

**Context**: A Java CLI tool that reads environment variables and writes a config file.

**Input**: "Add support for a `--output-format` flag (JSON or YAML)."

**Expected skill behavior**:
- Adds a flag to the CLI argument parsing
- Uses an `if-else` or a `switch` expression to pick the output format
- Does not introduce a `FormatStrategy` interface, a `FormatFactory`, or a domain model

**Behavior to avoid**:
- Applying the Strategy pattern to a two-option format selection in a CLI tool

**Approval criteria**:
- The flag works correctly
- The code is direct and readable without unnecessary abstractions

---

## Scenario 12: Complex Domain Project

**Context**: A Java financial platform managing credit limit approvals with multiple approval stages, risk scoring, and regulatory audit trails.

**Input**: "Add an automatic rejection when the credit score is below a threshold."

**Expected skill behavior**:
- Reads the existing approval workflow to understand the state machine
- Identifies the `CreditApplication` aggregate (or proposes one if absent)
- Adds the rejection logic as a state transition within the aggregate, enforced by domain rules
- Raises a `CreditApplicationRejected` domain event for audit purposes
- Writes unit tests for the aggregate behavior, not the HTTP layer

**Behavior to avoid**:
- Adding the rejection as a direct database update in the controller
- Ignoring the audit trail requirement

**Approval criteria**:
- The rejection is modeled as a domain state transition
- The event is recorded for audit
- Domain tests verify the rule

---

## Scenario 13: Object-Oriented Scenario

**Context**: A Java notification service with email and SMS implementations of a `NotificationSender` interface.

**Input**: "Add WhatsApp as a new notification channel."

**Expected skill behavior**:
- Creates a `WhatsAppNotificationSender` implementing the existing `NotificationSender` interface
- Registers it in the existing configuration or factory
- Does not modify the dispatch logic that already iterates over `NotificationSender` instances

**Behavior to avoid**:
- Adding a WhatsApp-specific branch in the dispatch method
- Rewriting other senders while adding the new one

**Approval criteria**:
- `WhatsAppNotificationSender` implements the existing interface
- No other senders are changed
- A test verifies dispatching to the WhatsApp channel

---

## Scenario 14: Functional Scenario

**Context**: A Java data pipeline that processes log entries through a sequence of `Function<LogEntry, LogEntry>` transformations.

**Input**: "Add a transformation that masks credit card numbers in log entries."

**Expected skill behavior**:
- Reads existing transformations — they are plain functions
- Implements `maskCreditCardNumbers` as a pure `Function<LogEntry, LogEntry>`
- Composes it into the existing pipeline using `andThen` or `compose`
- Writes a unit test for the function in isolation

**Behavior to avoid**:
- Introducing a `TransformationStrategy` interface and factory when existing transformations are plain lambdas
- Mutating the `LogEntry` in place when the pipeline expects immutable transformations

**Approval criteria**:
- The function is pure and testable without a database or HTTP call
- It integrates correctly with the existing pipeline
- Tests cover: no card numbers, one card, multiple cards, partial numbers

---

## Scenario 15: Validation Cannot Be Run

**Context**: The agent is working in an environment without a JDK or Maven installed.

**Input**: "Add input validation to the `ProductController.create` endpoint."

**Expected skill behavior**:
- Reads the controller and adds Bean Validation annotations (`@NotBlank`, `@Positive`, etc.) or manual validation
- Explicitly states: "The JDK and Maven are not available in this environment. The following validations were not run: `mvn compile`, `mvn test`. Manual review and CI execution are required."

**Behavior to avoid**:
- Claiming tests pass without having run them
- Refusing to implement the feature because the toolchain is unavailable

**Approval criteria**:
- The validation code is correct based on code analysis
- The response explicitly lists which validations could not be executed
