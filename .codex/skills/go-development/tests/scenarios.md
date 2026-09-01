# Go Skill Validation Scenarios

A matrix of scenarios to evaluate whether this skill correctly guides an agent working on Go projects.

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

**Context**: A Go HTTP service that manages products. The service has a `handler` and a `store` package. No pagination exists yet.

**Input**: "Add pagination support to the `GET /products` endpoint. The API should accept `page` and `per_page` query parameters."

**Expected skill behavior**:
- Inspects existing handler and store code before writing anything
- Identifies the existing patterns for query handling and response format
- Adds pagination at the handler level (parse params) and store level (LIMIT/OFFSET or cursor)
- Introduces a `Pagination` type only if it will be reused; otherwise uses local variables
- Writes table-driven tests for the parameter parsing and the paginated query
- Does not introduce a pagination framework or elaborate abstraction

**Behavior to avoid**:
- Creating a generic pagination library before understanding the use case
- Introducing a new architectural layer for a query parameter
- Changing unrelated code

**Approval criteria**:
- Pagination works correctly for `?page=2&per_page=10`
- Default values are applied when parameters are absent
- Invalid inputs return appropriate HTTP errors
- Tests cover happy path, missing params, and invalid values

---

## Scenario 2: Bug Fix

**Context**: A Go service reports that some HTTP responses have an extra trailing newline in the JSON body, causing client parsing issues.

**Input**: "Fix the extra newline in JSON responses from the user handler."

**Expected skill behavior**:
- Reads the handler code to find where JSON is encoded
- Identifies `json.Encoder` with `Encode` (which appends `\n`) vs `json.Marshal` (which does not)
- Makes a focused change: switch to `json.Marshal` + `w.Write`, or use `json.NewEncoder(w).Encode` and accept the newline (documenting why)
- Writes a test verifying the response body has no unwanted trailing characters

**Behavior to avoid**:
- Rewriting the entire response handling infrastructure
- Introducing a response wrapper type without a clear benefit

**Approval criteria**:
- The bug is fixed
- No regression in other endpoints
- The fix is one or two lines, not a refactor

---

## Scenario 3: Legacy Refactoring

**Context**: A 3-year-old Go service has a `util.go` file with 800 lines of mixed functions: string manipulation, date formatting, HTTP response writing, and database helpers.

**Input**: "Refactor `util.go` to improve organization."

**Expected skill behavior**:
- Reads the file and categorizes existing functions by responsibility
- Proposes an incremental plan: move functions to focused packages (e.g., `httputil`, `timeformat`) without breaking existing callers
- Moves one category at a time, updating imports
- Does not rename functions unless the old names are misleading in the new context
- Does not rewrite logic unless it is visibly incorrect

**Behavior to avoid**:
- Renaming all functions in one pass without updating callers
- Rewriting business logic while refactoring structure
- Creating a new `util` package that is just as generic

**Approval criteria**:
- All existing tests continue to pass
- Functions are in focused packages with clear names
- The change is reviewable in increments

---

## Scenario 4: Writing Tests

**Context**: A `discount` package calculates promotional discounts. It has no tests.

**Input**: "Write tests for the `ApplyDiscount` function."

**Expected skill behavior**:
- Reads the function signature and behavior before writing tests
- Writes table-driven tests with named cases
- Covers: standard discount, zero discount, 100% discount, discount exceeding total, negative input
- Uses only the public API (black-box test)
- Does not mock the function itself

**Behavior to avoid**:
- Testing private helper functions directly
- Using a mocking framework for a pure function
- Writing a single large test with multiple assertions without structure

**Approval criteria**:
- `go test ./discount/...` passes
- All meaningful cases are covered
- Test names clearly describe each scenario in English

---

## Scenario 5: Architecture Analysis

**Context**: A growing Go service mixes HTTP handler logic, business rules, and SQL queries in the same function.

**Input**: "The codebase is getting hard to maintain. How should we structure it?"

**Expected skill behavior**:
- Reads the existing code to understand actual complexity
- Assesses whether full Clean Architecture is justified or whether a simpler three-layer split (handler, service, repository) is sufficient
- Proposes the minimal architectural change that solves the maintenance problem
- Presents the trade-offs of different approaches
- Suggests an incremental migration plan, not a big-bang rewrite

**Behavior to avoid**:
- Immediately recommending microservices, event sourcing, or CQRS
- Proposing DDD aggregates for what appears to be a CRUD service
- Providing a one-size-fits-all architecture recommendation without reading the code

**Approval criteria**:
- The recommendation is proportionate to the observed complexity
- Trade-offs are clearly explained
- A concrete incremental plan is provided

---

## Scenario 6: Project Without Tests

**Context**: A Go CLI tool with no test files at all.

**Input**: "Add tests to this project."

**Expected skill behavior**:
- Reads the code to identify the most critical and testable functions
- Starts with the most valuable tests: core business logic, not `main()`
- Introduces `go test` patterns without adding a testing framework the project doesn't have
- Documents which areas were not covered and why (e.g., `main()` requires integration setup)

**Behavior to avoid**:
- Adding a testing framework that the project did not previously use without justification
- Writing tests that only cover trivial getters
- Claiming 100% coverage is the goal

**Approval criteria**:
- At least the core logic functions have tests
- `go test ./...` passes
- Gaps are documented

---

## Scenario 7: Project With Existing Conventions

**Context**: A Go service uses `errors.New` with specific message formats and a custom `apierror` package for HTTP error responses.

**Input**: "Add a new endpoint that returns a validation error when the request body is invalid."

**Expected skill behavior**:
- Reads existing endpoint handlers to understand how validation errors are currently returned
- Uses the existing `apierror` package and message format
- Does not introduce a new error format or library

**Behavior to avoid**:
- Returning a plain HTTP 400 with a different JSON structure
- Introducing `github.com/go-playground/validator` when the project does not use it

**Approval criteria**:
- The new endpoint's error responses are consistent with existing ones
- No new error handling package is introduced without justification

---

## Scenario 8: Unnecessary Complexity Request

**Context**: A Go HTTP service with three endpoints.

**Input**: "Add a plugin system so we can add new handlers dynamically at runtime without recompiling."

**Expected skill behavior**:
- Questions the actual requirement: is runtime plugin loading genuinely needed?
- Explains the cost: `plugin` package complexity, OS limitations, debugging difficulty
- Proposes a simpler alternative: a registry of handlers registered at startup
- Implements the simpler solution unless the runtime requirement is confirmed

**Behavior to avoid**:
- Implementing `plugin.Open` for a three-endpoint service
- Silently accepting the complexity without evaluating the actual need

**Approval criteria**:
- The agent challenges the premise before implementing
- A simpler alternative is proposed and justified
- If complexity is confirmed as truly required, it is implemented with clear documentation

---

## Scenario 9: Incomplete Requirements

**Context**: A Go service for managing documents.

**Input**: "Add document sharing."

**Expected skill behavior**:
- Identifies that "sharing" is underspecified: share with whom? Read-only or editable? Expiring links or persistent permissions?
- Asks one focused clarifying question before writing any code
- Does not implement a sharing system based on assumptions alone

**Behavior to avoid**:
- Building a full sharing system based on guessed requirements
- Refusing to engage at all due to ambiguity

**Approval criteria**:
- The agent asks at least one clarifying question
- The question is specific and covers the most critical unknown

---

## Scenario 10: Dependency Change

**Context**: A Go service uses `github.com/lib/pq` for PostgreSQL. The team wants to migrate to `pgx`.

**Input**: "Replace `lib/pq` with `pgx`."

**Expected skill behavior**:
- Identifies all files that import or use `lib/pq`
- Explains the API differences between the two libraries
- Proposes an incremental migration: one package at a time
- Updates `go.mod` and `go.sum` correctly
- Ensures existing tests still pass at each step

**Behavior to avoid**:
- Making all changes in a single commit without testing intermediate states
- Silently changing behavior that is driver-specific (e.g., placeholder format `$1` vs `?`)

**Approval criteria**:
- `go build ./...` succeeds after migration
- `go test ./...` passes
- `go.mod` has no unused dependencies

---

## Scenario 11: Small Project — DDD Not Needed

**Context**: A Go CLI tool that reads a CSV file and outputs a formatted report.

**Input**: "Add support for filtering rows by date range."

**Expected skill behavior**:
- Adds date range parsing and filtering with a simple function or flag
- Does not introduce entities, aggregates, repositories, or domain services

**Behavior to avoid**:
- Creating a `domain/` package with a `Row` aggregate for a CSV processing script

**Approval criteria**:
- The feature works correctly
- The code is a direct, idiomatic Go function or struct — not an over-engineered domain model

---

## Scenario 12: Complex Domain Project

**Context**: A Go service manages financial transactions with complex rules: approval workflows, fraud detection triggers, multi-currency conversion, and audit trails.

**Input**: "Add support for transaction reversal with approval tracking."

**Expected skill behavior**:
- Identifies that this domain is genuinely complex and has invariants
- Introduces or extends a `Transaction` domain type with a state machine
- Uses a domain event (`TransactionReversalRequested`) to decouple approval from the core transaction logic
- Applies DDD concepts proportionate to the complexity
- Writes tests for the domain rules (not just the HTTP layer)

**Behavior to avoid**:
- Implementing reversal as a direct database update without modeling the state transition
- Ignoring audit trail requirements

**Approval criteria**:
- Reversal logic is in the domain layer, not in the HTTP handler
- State transitions are explicit and tested
- The audit trail is written correctly

---

## Scenario 13: Object-Oriented Scenario

**Context**: A Go service has a notification system that must support email, SMS, and push channels.

**Input**: "Add Slack as a new notification channel."

**Expected skill behavior**:
- Reads the existing `Notifier` interface (or identifies it needs one)
- Implements a `SlackNotifier` struct satisfying the existing interface
- Registers it in the factory or registry used for other channels
- Does not change the notification dispatch logic

**Behavior to avoid**:
- Adding a Slack-specific code path in the dispatch function (open/closed principle violation)
- Rewriting existing channels while adding a new one

**Approval criteria**:
- `SlackNotifier` implements the existing interface
- The dispatch logic is unchanged
- A test verifies that Slack notifications are dispatched correctly

---

## Scenario 14: Functional Scenario

**Context**: A Go data pipeline transforms log lines through a series of filters and transformations.

**Input**: "Add a transformation that redacts email addresses from log lines."

**Expected skill behavior**:
- Reads existing transformation functions — they are pure functions taking and returning strings or structured records
- Implements `redactEmails(line string) string` as a pure function
- Plugs it into the existing pipeline composition
- Writes a table-driven unit test for the redaction logic

**Behavior to avoid**:
- Introducing a `Transformer` interface and factory when the existing design is functional
- Mutating a shared buffer instead of returning a new string

**Approval criteria**:
- The function is pure and testable in isolation
- It integrates correctly with the existing pipeline
- Tests cover: no emails (no change), single email, multiple emails, malformed address

---

## Scenario 15: Validation Cannot Be Run

**Context**: The agent is working in an environment without the Go toolchain installed.

**Input**: "Fix the nil pointer dereference in `OrderService.Cancel`."

**Expected skill behavior**:
- Reads the code and identifies the nil pointer cause
- Implements the fix correctly
- Explicitly states in the response: "The Go toolchain is not available in this environment. The following validations were not run: `go build`, `go vet`, `go test`. Manual review and CI execution are required."

**Behavior to avoid**:
- Claiming tests pass without having run them
- Refusing to fix the bug because the toolchain is unavailable

**Approval criteria**:
- The fix is correct based on code analysis
- The response clearly states which validations were not executed
- No false claims of test success
