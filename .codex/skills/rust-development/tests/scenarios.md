# Rust Skill Validation Scenarios

A matrix of scenarios to evaluate whether this skill correctly guides an agent working on Rust projects.

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

**Context**: A Rust HTTP service for managing products. Filtering by category is not yet implemented.

**Input**: "Add filtering by category to the `GET /products` endpoint."

**Expected skill behavior**:
- Reads the existing handler and service code before writing anything
- Identifies existing query parameter extraction conventions (Axum, Actix, etc.)
- Adds a `category` optional query parameter
- Updates the repository method or adds a new one to filter by category
- Writes unit tests for the filter logic and integration tests for the handler
- Does not introduce a generic `Filter<T>` trait for one query parameter

**Behavior to avoid**:
- Creating a generic query builder abstraction for one filter
- Changing existing handler signatures without reading how they are called

**Approval criteria**:
- `GET /products?category=books` returns only matching products
- `GET /products` returns all products
- Tests cover: matched products, unmatched category, missing parameter

---

## Scenario 2: Bug Fix

**Context**: A Rust service panics with `called unwrap() on a None value` when a user is not found.

**Input**: "Fix the panic in `UserService::get_profile` when the user does not exist."

**Expected skill behavior**:
- Reads the code to find the `unwrap()` call
- Replaces it with explicit error handling: return `Err(UserError::NotFound(id))`
- Updates the return type of the function if it was previously `User` instead of `Result<User, UserError>`
- Updates all callers to handle the new `Result`
- Writes a test verifying the `NotFound` error is returned for a missing user

**Behavior to avoid**:
- Replacing `unwrap()` with `expect("this should never happen")` — that still panics
- Returning a default `User` value when the user is not found without documenting the contract

**Approval criteria**:
- `cargo build` succeeds with no warnings
- The panic is eliminated and the `NotFound` case is handled correctly at all call sites
- A test verifies the `Err(UserError::NotFound(_))` response

---

## Scenario 3: Legacy Refactoring

**Context**: A `handlers.rs` file with 700 lines mixing HTTP parsing, business logic, database queries, and error formatting.

**Input**: "Refactor `handlers.rs` to improve organization."

**Expected skill behavior**:
- Reads the file and maps its distinct responsibilities
- Proposes moving business logic to a `service` module, database queries to a `repository` module
- Migrates one responsibility at a time, running `cargo test` after each step
- Defines traits for the repository if tests require substitution
- Does not rewrite business logic during the structural refactor

**Behavior to avoid**:
- Moving all code in one commit without running tests between steps
- Introducing a trait with no test double and no second implementation
- Rewriting logic while moving code

**Approval criteria**:
- `cargo test` passes after each incremental step
- Modules have clear names reflecting their responsibility
- The diff is reviewable incrementally

---

## Scenario 4: Writing Tests

**Context**: A `calculate_discount` function in a `pricing` module. No tests exist.

**Input**: "Write tests for `calculate_discount`."

**Expected skill behavior**:
- Reads the function signature and documented behavior
- Writes a `#[cfg(test)]` module with named test functions
- Covers: standard discount, zero discount, 100% discount, negative rate (error or panic?), subtotal of zero
- Uses descriptive English test names
- Tests the function via its public API

**Behavior to avoid**:
- Testing private helpers that are not part of the observable contract
- Using `mockall` to mock a pure arithmetic function
- Writing one test function with many unrelated assertions

**Approval criteria**:
- `cargo test pricing` passes
- All meaningful cases have a named test function
- Test names describe the scenario in snake_case English

---

## Scenario 5: Architecture Analysis

**Context**: A Rust service where HTTP handlers contain SQL queries and business rules inline.

**Input**: "How should we organize this codebase?"

**Expected skill behavior**:
- Reads the existing code to understand the domain complexity
- Assesses whether full Clean Architecture is justified or whether a pragmatic three-layer split (handler, service, repository) is sufficient
- Proposes an incremental migration plan
- Discusses trait-based boundaries only if tests require them
- Does not recommend a workspace split unless independent versioning is needed

**Behavior to avoid**:
- Recommending a DDD architecture with aggregates, domain events, and repositories for a simple CRUD service
- Recommending a microservices split for what is a single-concern service

**Approval criteria**:
- The recommendation is proportionate to the observed complexity
- An incremental first step is provided
- Trade-offs are explained clearly

---

## Scenario 6: Project Without Tests

**Context**: A Rust CLI tool with no test files.

**Input**: "Add tests to this project."

**Expected skill behavior**:
- Reads the code to identify the most critical and testable functions
- Adds `#[cfg(test)]` unit tests to the most important modules
- Adds at least one integration test in `tests/` if the public API is meaningful
- Documents which areas were not covered and why (e.g., CLI argument parsing is best covered by integration tests)

**Behavior to avoid**:
- Adding tests only for trivial getter functions
- Claiming 100% coverage as the goal

**Approval criteria**:
- `cargo test` passes
- Core logic has unit tests
- Gaps are documented

---

## Scenario 7: Project With Existing Conventions

**Context**: A Rust project uses `anyhow::Result` for error propagation throughout the application layer and `thiserror`-derived errors only in the domain layer.

**Input**: "Add a new endpoint that validates the request body."

**Expected skill behavior**:
- Reads how existing endpoints return errors
- Uses `anyhow::Result` in the handler layer and a `thiserror` error type for domain validation
- Does not introduce `Box<dyn Error>` when the project uses `anyhow`

**Behavior to avoid**:
- Introducing a third error handling approach inconsistent with existing code
- Converting all errors to strings with `.to_string()`

**Approval criteria**:
- Error handling is consistent with the existing pattern
- The validation error carries enough context for the caller to respond correctly

---

## Scenario 8: Unnecessary Complexity Request

**Context**: A Rust service that fetches user data from one data source.

**Input**: "Add a plugin system so we can swap data sources at runtime without recompiling."

**Expected skill behavior**:
- Questions whether runtime swapping is genuinely needed (most Rust apps swap at startup via configuration)
- Proposes using a trait object (`Box<dyn UserRepository>`) configured at startup as a simpler alternative to a full plugin system
- Implements the trait-based approach unless the true runtime-loading requirement is confirmed

**Behavior to avoid**:
- Using `dlopen` or dynamic library loading for a use case that trait objects cover
- Silently accepting the complexity without evaluating the actual need

**Approval criteria**:
- The agent challenges the premise
- A simpler alternative is proposed with rationale
- If dynamic loading is confirmed, it is implemented with `unsafe` properly documented

---

## Scenario 9: Incomplete Requirements

**Context**: A Rust billing service.

**Input**: "Add support for subscriptions."

**Expected skill behavior**:
- Identifies that "subscriptions" is underspecified: monthly or annual? Auto-renew? Cancellation? Proration? Trial periods?
- Asks one focused clarifying question before writing any code

**Behavior to avoid**:
- Building a full subscription system based on guessed requirements
- Refusing to engage at all

**Approval criteria**:
- At least one specific clarifying question is asked
- No code is written before the critical question is answered

---

## Scenario 10: Dependency Change

**Context**: A Rust service uses `reqwest` synchronously (blocking). The team wants to migrate to async.

**Input**: "Migrate from blocking reqwest to async reqwest."

**Expected skill behavior**:
- Lists all usages of `reqwest::blocking`
- Identifies that migrating to async requires the functions to become `async fn` and the call sites to `await`
- Adds the Tokio runtime if not already present
- Migrates one call site at a time
- Updates `Cargo.toml` to enable the `async-std` or `tokio` feature of `reqwest`
- Runs `cargo test` after each migration step

**Behavior to avoid**:
- Migrating all call sites at once without compiling between steps
- Wrapping async calls in `block_on` to avoid propagating `async` — that defeats the purpose

**Approval criteria**:
- `cargo build` succeeds with no warnings
- `cargo test` passes
- All HTTP calls are properly `await`ed

---

## Scenario 11: Small Project — DDD Not Needed

**Context**: A Rust CLI tool that renames files matching a pattern.

**Input**: "Add a `--dry-run` flag that shows what would be renamed without doing it."

**Expected skill behavior**:
- Adds a `dry_run: bool` flag to the CLI arguments struct (Clap)
- Passes it through to the rename logic
- Prints the planned renames without executing when `dry_run` is true
- Does not introduce a `RenameStrategy` trait for two code paths

**Behavior to avoid**:
- Creating an abstraction over file system operations for one flag

**Approval criteria**:
- `--dry-run` works correctly
- The implementation is direct and readable
- No trait or generic added without justification

---

## Scenario 12: Complex Domain Project

**Context**: A Rust financial service managing trade orders with complex execution rules, partial fills, cancellation policies, and audit trails.

**Input**: "Add support for partial order fills."

**Expected skill behavior**:
- Reads the existing `Order` type to understand the current state machine
- Models partial fill as a state transition: `Submitted` → `PartiallyFilled(filled_quantity)`
- Enforces the invariant in the type: `filled_quantity <= total_quantity`
- Adds a domain event `OrderPartiallyFilled` for audit purposes
- Writes unit tests for the state transition, including invalid transitions

**Behavior to avoid**:
- Adding partial fill as a direct database field update without modeling the state
- Ignoring the audit trail requirement

**Approval criteria**:
- The state transition is enforced at the type level
- Invalid transitions return `Err(OrderError::InvalidTransition { ... })`
- Domain events are recorded
- Unit tests verify the correct and incorrect transition cases

---

## Scenario 13: Object-Oriented Scenario (Trait-Based)

**Context**: A Rust notification service with `EmailNotifier` and `SmsNotifier` implementing a `Notifier` trait.

**Input**: "Add Slack as a new notification channel."

**Expected skill behavior**:
- Creates `SlackNotifier` implementing the existing `Notifier` trait
- Registers it in the existing configuration or dispatcher
- Does not modify the dispatch logic

**Behavior to avoid**:
- Adding a Slack-specific branch in the dispatch function
- Rewriting existing notifiers while adding the new one

**Approval criteria**:
- `SlackNotifier` implements the `Notifier` trait
- The dispatch logic is unchanged
- A unit test verifies the Slack notifier sends correctly

---

## Scenario 14: Functional Scenario

**Context**: A Rust data pipeline that processes log entries through a `Vec<Box<dyn Fn(LogEntry) -> LogEntry>>` of transformation functions.

**Input**: "Add a transformation that masks IP addresses in log entries."

**Expected skill behavior**:
- Reads the existing pipeline and recognizes the functional transformation pattern
- Implements `mask_ip_addresses(entry: LogEntry) -> LogEntry` as a pure function
- Adds it to the transformation pipeline
- Writes a unit test for the function in isolation

**Behavior to avoid**:
- Creating a `Transformer` trait when the existing design uses plain functions or closures
- Mutating the `LogEntry` in place when the pipeline expects pure transformations

**Approval criteria**:
- The function is pure: takes ownership of a `LogEntry`, returns a new one
- It integrates into the pipeline without changing its structure
- Tests cover: no IP addresses, one address, multiple addresses

---

## Scenario 15: Validation Cannot Be Run

**Context**: The agent is working in an environment without the Rust toolchain.

**Input**: "Fix the off-by-one error in the pagination calculation in `page_slice.rs`."

**Expected skill behavior**:
- Reads the code and identifies the correct fix (typically `start_index = (page - 1) * per_page`)
- Implements the fix
- Explicitly states: "The Rust toolchain (cargo build, cargo test) is not available in this environment. The following validations were not run: `cargo check`, `cargo clippy`, `cargo test`. Manual review and CI execution are required before merging."

**Behavior to avoid**:
- Claiming tests pass without having run them
- Refusing to fix the bug because the toolchain is unavailable

**Approval criteria**:
- The fix is correct based on static analysis of the code
- The response explicitly lists which validations could not be executed
- No false claims of compilation or test success
