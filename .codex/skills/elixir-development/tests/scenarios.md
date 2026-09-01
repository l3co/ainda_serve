# Elixir Development — Test Scenarios

These scenarios validate whether an agent correctly applies the `elixir-development` skill. Each scenario describes a realistic task. Evaluate the agent's response against the expected behavior.

---

## Scoring Rubric

| Score | Meaning |
|---|---|
| **3 — Pass** | All expected behaviors exhibited; all approval criteria met |
| **2 — Partial** | Most expected behaviors; one or two criteria missed |
| **1 — Marginal** | Core intent partial; behavior to avoid observed |
| **0 — Fail** | Expected behavior absent or task refused without justification |

---

## Scenario 01 — Basic GenServer

**Request:** "Create a GenServer that caches product prices and supports get and put operations."

**Expected behavior:**
- Defines a public client API (`start_link/1`, `get/2`, `put/3`)
- Implements `handle_call` for `get` (synchronous, result needed)
- Implements `handle_cast` for `put` (fire-and-forget)
- Uses `@impl true` on all callbacks
- Includes `@spec` for public functions
- Does not use a GenServer if a simpler ETS table or Agent was already available in the project

**Behavior to avoid:**
- Using `handle_cast` for operations where the caller needs the result
- Missing `@spec` on public functions
- Registering the process with a global name without justification

**Approval criteria:**
- Client API separated from server callbacks
- `call` used for `get`, `cast` used for `put`
- `@impl true` on all callbacks
- `@spec` present on all public functions

---

## Scenario 02 — Ecto Changeset Validation

**Request:** "Write a registration changeset for a User schema that validates email format, minimum password length of 12 characters, and uniqueness of email."

**Expected behavior:**
- Uses `cast/3` to permit only declared fields
- Uses `validate_required/2` for mandatory fields
- Uses `validate_format/3` for email
- Uses `validate_length/3` for password
- Uses `unique_constraint/2` for email
- Does NOT store the plain password — hashes it before inserting
- Returns `{:ok, user}` or `{:error, changeset}` from the context function

**Behavior to avoid:**
- Inserting without a changeset
- Storing the plain password
- Using `String.length` instead of `validate_length`
- Trusting input without casting

**Approval criteria:**
- All five validations present
- Password hashed before persistence
- Context function returns tagged tuple

---

## Scenario 03 — Pattern Matching in Function Heads

**Request:** "Refactor this if/else chain to use multiple function clauses with pattern matching."

```elixir
def describe_result(result) do
  if result == :ok do
    "success"
  else
    if is_binary(result) do
      "message: #{result}"
    else
      "unknown"
    end
  end
end
```

**Expected behavior:**
- Uses three function clauses with pattern matching
- Removes the if/else nesting
- Preserves identical behavior

**Behavior to avoid:**
- Leaving `if` conditionals in the body
- Introducing `cond` when function clauses are cleaner

**Approval criteria:**
- Three function clauses with pattern-matched heads
- Same output for `:ok`, a binary, and other values
- No `if` in the refactored version

---

## Scenario 04 — with for Checkout Flow

**Request:** "Implement a checkout function that gets the user, gets the active cart, verifies cart ownership, and creates an order. Handle each error distinctly."

**Expected behavior:**
- Uses `with` for the sequential operations
- Has an `else` clause that disambiguates errors from different steps
- Returns `{:ok, order}` or a specific `{:error, reason}` for each failure mode

**Behavior to avoid:**
- Nested `case` expressions without `with`
- `with` without `else` (all errors look the same)
- Returning a generic `{:error, :failed}` for all failure cases

**Approval criteria:**
- `with` used for sequential steps
- `else` clause present
- Each failure mode returns a distinct error

---

## Scenario 05 — Context Module Design

**Request:** "Create a context module for order management that exposes functions to create, get by ID, and list orders by customer."

**Expected behavior:**
- Creates a plain Elixir module (no GenServer, no Agent)
- Functions return `{:ok, result}` or `{:error, reason}`
- `get_order/1` handles the `nil` case explicitly (not `Repo.get!/1`)
- `list_orders_by_customer/1` uses composable Ecto queries
- The web layer is not imported into the context

**Behavior to avoid:**
- Using `Repo.get!` without handling the not-found case
- Importing Phoenix or web-layer modules
- Defining Ecto schema inside the context module

**Approval criteria:**
- Plain module with context functions
- All functions return tagged tuples
- Not-found handled without raising
- Ecto query uses parameterized binding

---

## Scenario 06 — Atom from User Input (Security)

**Request:** "Parse the `role` field from incoming JSON params and convert it to an atom to store in the database."

**Risk:** Agent uses `String.to_atom(params["role"])`.

**Expected behavior:**
- Validates the role against a known allowlist
- Uses `String.to_existing_atom/1` or matches on string values
- Returns an error for unrecognized roles

**Behavior to avoid:**
- `String.to_atom(params["role"])`
- `:"#{params["role"]}"`

**Approval criteria:**
- No `String.to_atom/1` on unchecked input
- Explicit allowlist or `Ecto.Enum` used
- Invalid roles rejected

---

## Scenario 07 — Supervisor Configuration

**Request:** "Add a Supervisor to the OTP tree that manages three notification workers, where each worker should restart independently on failure."

**Expected behavior:**
- Uses `:one_for_one` strategy (workers are independent)
- Defines child specs with appropriate restart options
- Adds the Supervisor to the root supervisor's child list
- Documents why `:one_for_one` was chosen

**Behavior to avoid:**
- Using `:one_for_all` without justification
- Missing `max_restarts` and `max_seconds` configuration when repeated crashes are a risk
- Not adding the supervisor to the OTP tree

**Approval criteria:**
- `:one_for_one` used with justification
- Workers are children of the new supervisor
- New supervisor is registered in the application tree

---

## Scenario 08 — ExUnit Test for a Context Function

**Request:** "Write ExUnit tests for `Accounts.create_user/1` covering the happy path, missing email, and duplicate email cases."

**Expected behavior:**
- Uses `DataCase` with async enabled
- Groups tests under `describe "create_user/1"`
- Tests `{:ok, user}` for valid attributes
- Tests `{:error, changeset}` with `errors_on(changeset)` for missing email
- Tests `{:error, changeset}` for duplicate email after inserting once
- Does not use `Process.sleep/1`

**Behavior to avoid:**
- Using `assert {:error, _}` without checking the specific error
- Using `Repo.insert!` instead of the context function
- Missing the duplicate email test

**Approval criteria:**
- Three test cases present
- `describe` block used
- `errors_on/1` used for changeset error assertions
- Async is enabled

---

## Scenario 09 — Pipe Operator Refactoring

**Request:** "Refactor this nested function call to use the pipe operator."

```elixir
def process(input) do
  normalize(trim(String.downcase(String.trim(input))))
end
```

**Expected behavior:**
- Refactors to a pipe chain starting with `input`
- Preserves identical behavior
- Does not use the pipe operator when a simpler expression would be clearer

**Behavior to avoid:**
- Reversing the order of operations
- Introducing intermediate `let`-style bindings when the pipe is cleaner

**Approval criteria:**
- Pipe chain starts with `input`
- Same four transformations in the same order
- Result is identical

---

## Scenario 10 — Ecto Query Composition

**Request:** "Write a composable Ecto query that lists orders filtered by optional customer_id, status, and minimum total amount."

**Expected behavior:**
- Starts with a base query
- Applies each filter only when the parameter is present
- Uses parameterized bindings (`^value`) in `where` clauses
- Does not use string interpolation in SQL fragments

**Behavior to avoid:**
- Building queries with string interpolation
- Non-composable if/else chains that repeat the base query
- Ignoring the optional nature of the filters (requiring all three)

**Approval criteria:**
- Base query separated from filter application
- Each filter is independently composable
- All bindings are parameterized

---

## Scenario 11 — Logger with Metadata

**Request:** "Add structured logging to the payment processing flow, including order ID and customer ID in every log entry."

**Expected behavior:**
- Uses `Logger.metadata/1` to set context at the start of the flow
- Uses `Logger.info/2` with keyword metadata for key events
- Does not log payment card numbers, CVV, or other sensitive payment data
- Uses `:telemetry.execute/3` for measurable events (optional but preferred)

**Behavior to avoid:**
- `IO.inspect` or `IO.puts` for logging
- Logging the full payment params including sensitive fields
- Using string interpolation instead of metadata keys

**Approval criteria:**
- `Logger.metadata/1` used at flow entry
- Structured logging calls with keyword args
- No PII or payment details in log entries

---

## Scenario 12 — Secrets in Configuration

**Request:** "Configure the Stripe secret key for production."

**Risk:** Agent adds the secret to `config/prod.exs` or hardcodes it.

**Expected behavior:**
- Uses `config/runtime.exs` with `System.fetch_env!("STRIPE_SECRET_KEY")`
- Does not add the key to compile-time config files
- Notes that the variable must be set in the production environment

**Behavior to avoid:**
- `config :my_app, stripe_key: "sk_live_..."` in any config file
- Hardcoding in application code
- Using `System.get_env/1` without a fallback strategy for missing values

**Approval criteria:**
- Secret in `runtime.exs`
- `System.fetch_env!/1` used (fails fast on missing variable)
- No secret value in any config file

---

## Scenario 13 — Phoenix Controller with Authorization

**Request:** "Add a `show` action to the order controller that returns the order by ID, ensuring the current user owns it."

**Expected behavior:**
- Reads the current user from `conn.assigns.current_user` (set by auth plug)
- Fetches the order by ID
- Verifies the order belongs to the current user before returning it
- Returns 404 for not found; 403 for unauthorized
- Does not trust `user_id` from the request body or params

**Behavior to avoid:**
- Trusting `user_id` from `params`
- Returning the order without ownership check (IDOR vulnerability)
- Returning 200 with an empty response when unauthorized

**Approval criteria:**
- Auth comes from `conn.assigns`
- Ownership check present
- 404 for not found, 403 for unauthorized
- No param-based user ID

---

## Scenario 14 — Mox for External Service

**Request:** "Write an ExUnit test for a notification service that sends an email via an external provider."

**Expected behavior:**
- Defines a behaviour for the email sender
- Uses `Mox.defmock` in `test/support/mocks.ex`
- Configures the mock in `config/test.exs`
- Uses `expect/3` to set up the call expectation
- Uses `verify_on_exit!/1` in the test setup

**Behavior to avoid:**
- Making a real HTTP call to the email provider in the test
- Mocking the module under test
- Using `Application.put_env/3` for mock injection without teardown

**Approval criteria:**
- Behaviour defined for the external dependency
- `Mox` used for the mock
- `verify_on_exit!` present
- No real network call

---

## Scenario 15 — GenServer Without Justification

**Request:** "Create a module that calculates the total price of a cart given a list of items with price and quantity."

**Risk:** Agent creates an unnecessary GenServer for what is a pure calculation.

**Expected behavior:**
- Implements the calculation as a plain module function
- Does not create a GenServer, Agent, or process
- Returns the result directly

**Behavior to avoid:**
- Wrapping the calculation in a GenServer
- Adding a Supervisor for a stateless computation
- Creating an `Agent` to store intermediate results

**Approval criteria:**
- Pure function module with no process spawning
- Function signature takes items as argument, returns result
- No `use GenServer` or `use Agent`
