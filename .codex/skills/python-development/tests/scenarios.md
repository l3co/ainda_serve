# Python Skill Validation Scenarios

A matrix of scenarios to evaluate whether this skill correctly guides an agent working on Python projects.

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

**Context**: A FastAPI service managing products. No filtering by price range exists yet.

**Input**: "Add filtering by price range to the `GET /products` endpoint."

**Expected skill behavior**:
- Reads the existing router and service code before writing anything
- Identifies existing query parameter conventions and response format
- Adds `min_price` and `max_price` optional query parameters
- Updates the service or repository function to filter accordingly
- Writes pytest tests covering: both parameters, only min, only max, neither
- Does not introduce a generic filter framework for one new parameter

**Behavior to avoid**:
- Creating a `FilterSpecification` class hierarchy for two optional query parameters
- Changing unrelated routes or models

**Approval criteria**:
- `GET /products?min_price=100&max_price=500` returns correctly filtered results
- Tests cover happy path and edge cases (no products in range, invalid values)
- Code matches existing project conventions

---

## Scenario 2: Bug Fix

**Context**: A Python function crashes with `KeyError` when a config key is missing.

**Input**: "Fix the `KeyError` in `load_config` when `DATABASE_URL` is not set."

**Expected skill behavior**:
- Reads `load_config` to understand how keys are accessed
- Determines whether a missing key is a recoverable state or a startup error
- If startup error: raises a `ValueError` or `RuntimeError` with a clear message
- If recoverable: uses `dict.get` with a documented default
- Writes a test reproducing the missing key case

**Behavior to avoid**:
- Wrapping the entire function in a broad `except Exception` to hide the error
- Returning `None` silently when a missing key is a configuration error

**Approval criteria**:
- The `KeyError` is eliminated
- The new behavior is explicit and documented
- A test verifies the missing key case

---

## Scenario 3: Legacy Refactoring

**Context**: A Python module `helpers.py` with 600 lines mixing string formatting, date utilities, HTTP helpers, and database query builders.

**Input**: "Refactor `helpers.py` to improve organization."

**Expected skill behavior**:
- Reads the file and categorizes functions by responsibility
- Proposes moving functions to focused modules: `formatting.py`, `date_utils.py`, `http_utils.py`
- Migrates one category at a time, updating imports in callers
- Does not rename functions unless the name is genuinely misleading
- Does not rewrite business logic during a structural refactor

**Behavior to avoid**:
- Renaming all functions without updating their callers in the same commit
- Introducing an ABC or Protocol hierarchy for simple utility functions
- Rewriting logic while reorganizing structure

**Approval criteria**:
- All existing tests pass
- Functions live in modules named after what they provide
- The refactoring is delivered in reviewable increments

---

## Scenario 4: Writing Tests

**Context**: A `discount.py` module with a `calculate_discount` function. No tests exist.

**Input**: "Write pytest tests for `calculate_discount`."

**Expected skill behavior**:
- Reads the function signature and documentation
- Writes parameterized tests covering: standard discount, zero discount, full discount, negative rate (error), rate above 1 (error), zero subtotal
- Uses `pytest.raises` for error cases
- Names tests descriptively in English

**Behavior to avoid**:
- Mocking the function itself
- Writing a single large test function with many unrelated assertions
- Testing Python's arithmetic operators rather than the function's behavior

**Approval criteria**:
- `pytest` passes
- All meaningful cases have a named test or parameter row
- Test names follow the `test_<what>_<when>_<expected>` pattern

---

## Scenario 5: Architecture Analysis

**Context**: A Python monolith with Django views that contain SQL queries, business logic, and email sending in the same function.

**Input**: "How should we organize this codebase?"

**Expected skill behavior**:
- Reads existing views and models before responding
- Assesses actual complexity: is a full Clean Architecture justified, or is a pragmatic service layer sufficient?
- Proposes extracting service functions and repository functions as a first step
- Explains trade-offs between approaches
- Provides an incremental migration path

**Behavior to avoid**:
- Recommending microservices for a monolith with manageable complexity
- Recommending DDD aggregates for what are essentially database CRUD operations
- Giving a generic answer without reading the code

**Approval criteria**:
- The recommendation is proportionate to the observed complexity
- An incremental, low-risk first step is provided
- Trade-offs are explained

---

## Scenario 6: Project Without Tests

**Context**: A Python CLI tool with no test files.

**Input**: "Add tests to this project."

**Expected skill behavior**:
- Reads the CLI code to identify the most critical and testable functions
- Adds pytest tests starting with the core logic, not `main()`
- Uses fixtures for test data
- Documents which areas were not covered and why (e.g., `main()` requires subprocess testing)

**Behavior to avoid**:
- Writing tests only for trivial string formatting
- Introducing a new testing framework the project didn't have
- Claiming all edge cases are covered when they are not

**Approval criteria**:
- Core logic functions have tests
- `pytest` passes
- Gaps are documented

---

## Scenario 7: Project With Existing Conventions

**Context**: A Python project uses `structlog` for structured logging with a specific event format: `log.info("event_name", key=value)`.

**Input**: "Add logging to the `process_payment` function."

**Expected skill behavior**:
- Reads existing logging calls to match the event format and key style
- Adds `log.info("payment_processed", order_id=..., amount_in_cents=...)` using the same pattern
- Does not import `logging` and use `logger.info("Payment processed for order %s", order_id)` if the project uses `structlog`

**Behavior to avoid**:
- Using the standard `logging` module when the project uses `structlog`
- Adding print statements instead of structured logs

**Approval criteria**:
- Logging is consistent with existing calls
- No new logging library is imported

---

## Scenario 8: Unnecessary Complexity Request

**Context**: A Python function that applies one of two discount types.

**Input**: "Implement the Strategy pattern for discount calculation."

**Expected skill behavior**:
- Questions whether two strategies that already exist as plain functions genuinely need a Strategy pattern
- Explains the trade-off: adding a `DiscountStrategy` Protocol and two implementations vs. using a simple `if-else` or passing a callable
- Recommends the simpler approach unless the number of strategies is confirmed to grow

**Behavior to avoid**:
- Immediately creating an ABC with two implementations and a factory for two existing functions

**Approval criteria**:
- The agent challenges the premise
- A simpler alternative is proposed with a rationale
- If multiple strategies are confirmed, the implementation is proportionate

---

## Scenario 9: Incomplete Requirements

**Context**: A Python service for user management.

**Input**: "Add user roles."

**Expected skill behavior**:
- Identifies that "roles" is underspecified: what roles exist? Is it a single role or multiple? Are permissions attached to roles? Is there role inheritance?
- Asks one focused clarifying question

**Behavior to avoid**:
- Building a full RBAC system based on guessed requirements
- Refusing to engage at all

**Approval criteria**:
- At least one specific clarifying question is asked
- No code is written before the question is answered

---

## Scenario 10: Dependency Change

**Context**: A Python project uses `requests` for HTTP. The team wants to migrate to `httpx` for async support.

**Input**: "Replace `requests` with `httpx`."

**Expected skill behavior**:
- Lists all files importing `requests`
- Maps the API differences (session handling, response interface, async)
- Migrates files one at a time
- Updates `pyproject.toml` or `requirements.txt`
- Verifies tests pass after each migration step

**Behavior to avoid**:
- Migrating all files in one pass without running tests between steps
- Silently changing the sync/async behavior of HTTP calls

**Approval criteria**:
- `pytest` passes after migration
- No remaining `requests` imports in the migrated files
- `httpx` is declared in the project dependencies

---

## Scenario 11: Small Project — DDD Not Needed

**Context**: A Python script that reads environment variables and generates a `.env` file.

**Input**: "Add support for a `--prefix` flag to namespace variables."

**Expected skill behavior**:
- Adds a `--prefix` argument to the CLI parser
- Applies the prefix in the existing variable output logic
- Does not introduce a `VariableNamePolicy` class or a DDD-inspired domain model

**Behavior to avoid**:
- Creating domain entities for environment variables in a simple script

**Approval criteria**:
- The flag works correctly
- The implementation is a few lines, not a class hierarchy

---

## Scenario 12: Complex Domain Project

**Context**: A Python service managing insurance claims with approval workflows, fraud detection, regulatory audit requirements, and multi-party communication.

**Input**: "Add automatic claim suspension when fraud indicators exceed the threshold."

**Expected skill behavior**:
- Reads the existing claim model and service to understand the state machine
- Identifies that claim suspension is a domain state transition with invariants
- Implements the transition in the domain service or model, not in the HTTP handler
- Raises a domain event or records an audit entry for the suspension
- Writes unit tests for the domain rule

**Behavior to avoid**:
- Adding the suspension as a direct database `UPDATE` in the router
- Ignoring the audit requirement

**Approval criteria**:
- The suspension is modeled as a domain operation with explicit state tracking
- The audit entry is created
- Tests verify the domain rule

---

## Scenario 13: Object-Oriented Scenario

**Context**: A Python notification system with `EmailSender` and `SmsSender` classes implementing a `NotificationSender` Protocol.

**Input**: "Add Slack as a new notification channel."

**Expected skill behavior**:
- Creates `SlackSender` implementing the existing `NotificationSender` Protocol
- Registers it in the existing configuration or factory
- Does not modify the dispatch logic

**Behavior to avoid**:
- Adding a Slack-specific branch in the dispatch function
- Changing the Protocol or other existing senders

**Approval criteria**:
- `SlackSender` satisfies the Protocol
- The dispatch logic is unchanged
- A test verifies Slack notification dispatch

---

## Scenario 14: Functional Scenario

**Context**: A Python data pipeline that processes log entries through a list of `Callable[[LogEntry], LogEntry]` transformations.

**Input**: "Add a transformation that masks phone numbers in log entries."

**Expected skill behavior**:
- Reads the existing pipeline — transformations are plain functions
- Implements `mask_phone_numbers(entry: LogEntry) -> LogEntry` as a pure function
- Adds it to the existing pipeline list
- Writes a unit test for the function in isolation

**Behavior to avoid**:
- Creating a `TransformationStrategy` ABC when the existing design uses callables
- Mutating the `LogEntry` in place when the pipeline expects pure transformations

**Approval criteria**:
- The function is pure and tested in isolation
- It integrates into the pipeline without changing its structure
- Tests cover: no phone numbers, one number, multiple numbers

---

## Scenario 15: Validation Cannot Be Run

**Context**: The agent is working in an environment without a Python runtime or pytest available.

**Input**: "Fix the `TypeError` in `invoice_builder.py` when `line_items` is `None`."

**Expected skill behavior**:
- Reads the code and identifies the None check that is missing
- Implements the fix correctly
- Explicitly states: "The Python runtime and pytest are not available in this environment. The following validations were not run: `python -m py_compile`, `pytest`. Manual review and CI execution are required before merging."

**Behavior to avoid**:
- Claiming tests pass without having run them
- Refusing to fix the bug because the runtime is unavailable

**Approval criteria**:
- The fix is correct based on static code analysis
- The response clearly declares which validations could not be executed
