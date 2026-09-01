# React Skill Validation Scenarios

A matrix of scenarios to evaluate whether this skill correctly guides an agent working on React projects.

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

**Context**: A React product listing page. Products can be browsed but not filtered by category yet.

**Input**: "Add category filtering to the product list."

**Expected skill behavior**:
- Reads the existing `ProductList` component and data fetching hook
- Adds a category filter control (select or radio buttons) with accessible label
- Passes the selected category to the existing or updated data fetching hook
- Writes tests using React Testing Library: selecting a category updates the displayed products
- Does not introduce a global state manager for one local filter value

**Behavior to avoid**:
- Adding Redux or Zustand for a single component's local filter state
- Creating a generic filter framework before understanding future filter requirements

**Approval criteria**:
- The filter control is accessible (labeled, keyboard navigable)
- Tests verify behavior from the user's perspective
- Selecting a category shows only matching products
- "All" option shows all products

---

## Scenario 2: Bug Fix

**Context**: A `CheckoutForm` component shows a stale cart total after the user removes an item.

**Input**: "Fix the stale total in the checkout form after item removal."

**Expected skill behavior**:
- Reads the component to identify where the total is calculated
- Identifies that the total is computed from a stale closure or a stale reference in `useEffect`
- Fixes the dependency array or derives the total directly during render
- Writes a test verifying the total updates after item removal

**Behavior to avoid**:
- Using `useRef` to bypass React's state model
- Adding an explicit `recalculateTotal` event to manually sync state

**Approval criteria**:
- Removing an item immediately updates the displayed total
- The fix uses React's data flow correctly (derive from state, not synchronize two pieces of state)
- A test verifies the updated total

---

## Scenario 3: Legacy Refactoring

**Context**: A 400-line `UserDashboard` component that handles data fetching, business logic calculations, and three distinct panels: notifications, recent orders, and account settings.

**Input**: "Refactor `UserDashboard` to make it easier to maintain."

**Expected skill behavior**:
- Reads the component to map its distinct responsibilities
- Extracts one panel at a time into focused sub-components
- Extracts data fetching into custom hooks (`useNotifications`, `useRecentOrders`)
- Keeps pure calculation logic outside components as plain functions
- Does not introduce global state or context for data that was previously local

**Behavior to avoid**:
- Splitting the component into micro-components with no clear responsibility boundary
- Introducing context or Redux for state that only one panel uses
- Rewriting business logic while restructuring component boundaries

**Approval criteria**:
- All existing tests pass
- Each extracted component has a clear name reflecting its purpose
- Data fetching is in custom hooks
- The refactoring is delivered in reviewable increments

---

## Scenario 4: Writing Tests

**Context**: A `LoginForm` component with email and password fields. No tests exist.

**Input**: "Write tests for the `LoginForm` component."

**Expected skill behavior**:
- Writes tests using React Testing Library with `getByRole` and `getByLabelText`
- Covers: successful submission calls `onLogin` with email and password; empty email shows validation error; empty password shows validation error; shows loading state while submitting; shows error message on failed login
- Uses `userEvent` for typing and clicking
- Does not test internal state values directly

**Behavior to avoid**:
- Using `getByClassName` or querying by component name
- Testing which React hooks the form uses internally
- Writing a snapshot test as the primary coverage

**Approval criteria**:
- Test suite passes
- Tests query by role and label — not by class or implementation detail
- All user-visible states (empty, loading, error, success) are covered
- Test names describe user-visible behavior in English

---

## Scenario 5: Architecture Analysis

**Context**: A React application where API calls are scattered across components using `useEffect` + `fetch`.

**Input**: "How should we handle data fetching in this application?"

**Expected skill behavior**:
- Reads existing components to understand current data fetching patterns
- Assesses whether the project already has React Query, SWR, or similar
- Recommends consolidating data fetching into custom hooks as a minimal first step
- Discusses whether React Query/SWR is justified based on actual data complexity
- Provides an incremental migration path

**Behavior to avoid**:
- Immediately recommending Redux Thunk or RTK Query for simple data fetching
- Recommending a generic data fetching layer without reading the current code

**Approval criteria**:
- The recommendation is proportionate to the observed complexity
- A concrete first step is provided
- The trade-offs of each approach are explained

---

## Scenario 6: Project Without Tests

**Context**: A React application with no test files at all.

**Input**: "Add tests to this React app."

**Expected skill behavior**:
- Reads the components to identify the most critical and testable ones
- Starts with the components that have the most business value: forms, checkout flows, critical displays
- Writes React Testing Library tests from the user's perspective
- Documents which components were not covered and why

**Behavior to avoid**:
- Writing snapshot tests for every component
- Testing presentational components with no logic before testing form validation
- Introducing a testing framework the project does not have

**Approval criteria**:
- Critical user interactions have tests
- Test suite passes
- Gaps are documented

---

## Scenario 7: Project With Existing Conventions

**Context**: A React project uses Zustand for global state and React Query for data fetching. The pattern established is: React Query for server state, Zustand for client-only UI state.

**Input**: "Add a notification badge showing the unread count from the API."

**Expected skill behavior**:
- Reads how other server data is fetched — recognizes the React Query pattern
- Implements the unread count fetch using React Query (`useQuery`)
- Does not add the server-fetched count to Zustand (that would violate the established pattern)

**Behavior to avoid**:
- Fetching and storing the unread count in Zustand
- Using a `useEffect` + `useState` pattern when the project established React Query for API data

**Approval criteria**:
- The unread count is fetched using React Query
- The badge updates when the query re-fetches
- The implementation matches the established pattern

---

## Scenario 8: Unnecessary Complexity Request

**Context**: A simple React counter component.

**Input**: "Refactor the counter to use a state machine."

**Expected skill behavior**:
- Questions whether a counter genuinely benefits from a state machine
- Explains the cost: adding XState or a similar library for increment/decrement
- Recommends keeping `useState` unless there are complex transitions, forbidden states, or async operations
- Implements the state machine only if the user confirms it is genuinely needed

**Behavior to avoid**:
- Adding XState to a counter without questioning the value

**Approval criteria**:
- The agent challenges the premise
- A simpler alternative is proposed with a rationale
- If a state machine is confirmed, the implementation is minimal and justified

---

## Scenario 9: Incomplete Requirements

**Context**: A React e-commerce application.

**Input**: "Add wishlists."

**Expected skill behavior**:
- Identifies missing information: local wishlist (no auth) or server-persisted? One wishlist or multiple? Guest users? Shareable?
- Asks one focused clarifying question before writing any code

**Behavior to avoid**:
- Building a full multi-wishlist system with sharing based on guessed requirements
- Refusing to engage at all

**Approval criteria**:
- At least one specific clarifying question is asked
- No code is written before the critical question is answered

---

## Scenario 10: Dependency Change

**Context**: A React app uses the deprecated `react-scripts` (CRA). The team wants to migrate to Vite.

**Input**: "Migrate from Create React App to Vite."

**Expected skill behavior**:
- Lists the differences: build config, environment variable naming (`REACT_APP_` → `VITE_`), `index.html` location, dev server config
- Provides a step-by-step migration: install Vite, create `vite.config.ts`, update `index.html`, update env vars, remove CRA scripts
- Updates `package.json` scripts
- Verifies the dev server starts and the build succeeds

**Behavior to avoid**:
- Making all changes in one pass without verifying intermediate steps
- Silently dropping source maps, proxy configuration, or environment variables

**Approval criteria**:
- The dev server starts (`vite dev` equivalent)
- The build succeeds (`vite build`)
- Existing functionality is unchanged
- Environment variables are correctly renamed

---

## Scenario 11: Small Project — No Global State Needed

**Context**: A single-page React app with a product filter and a product list on the same page.

**Input**: "Add a price range filter."

**Expected skill behavior**:
- Adds `useState` for the price range in the parent component
- Passes the filter values down to the product list as props
- Does not introduce Redux, Context, or Zustand for two values used by siblings

**Behavior to avoid**:
- Adding global state management for data that is used only on this one page

**Approval criteria**:
- The filter state is local to the page component
- Props flow down cleanly
- The implementation is a few lines, not an infrastructure addition

---

## Scenario 12: Complex Domain Project

**Context**: A React app for financial portfolio management with real-time price updates, complex computed fields across multiple instruments, shared state across many screens, and audit history.

**Input**: "Add a real-time portfolio value display that updates as prices change."

**Expected skill behavior**:
- Reads the existing state management setup (likely Redux or Zustand for this scale)
- Implements the WebSocket subscription in a custom hook
- Dispatches price updates to the global store
- Derives the portfolio value as a selector/computed value — does not store derived data
- Tests the hook with a mock WebSocket
- Confirms the display updates correctly

**Behavior to avoid**:
- Using `useState` in a leaf component for data that multiple screens need
- Storing the derived portfolio value in state (source of truth should be price + positions)

**Approval criteria**:
- Real-time updates flow correctly from WebSocket to UI
- The portfolio value is derived, not stored
- The implementation uses the existing state management pattern

---

## Scenario 13: Object-Oriented Scenario (Component Composition)

**Context**: A React design system with `Button`, `IconButton`, and `SubmitButton` components that share base styling but differ in icon, loading state, and type.

**Input**: "Add a `DangerButton` variant."

**Expected skill behavior**:
- Reads how existing button variants are implemented (composition, variant prop, etc.)
- Adds `DangerButton` using the same pattern: variant prop value or a composed component
- Does not create a new class hierarchy or duplicate the base button code

**Behavior to avoid**:
- Creating a `DangerButton` that copies all the base `Button` JSX
- Changing the behavior of existing button variants

**Approval criteria**:
- `DangerButton` shares the base styling through composition
- No duplication of base button logic
- A test verifies the danger styling is applied

---

## Scenario 14: Functional Scenario (Derived State)

**Context**: A React shopping cart where the total and item count are currently stored as separate state values updated manually.

**Input**: "Fix the cart total that sometimes shows the wrong value."

**Expected skill behavior**:
- Identifies that the root cause is having derived values (`total`, `count`) stored as separate state that can go out of sync
- Removes the separate state values
- Derives total and count from the `items` array during render: `const total = items.reduce(…)`
- Writes a test verifying the total is always consistent with the items

**Behavior to avoid**:
- Adding another `useEffect` to synchronize the total with the items
- Using `useRef` to track the "previous total"

**Approval criteria**:
- The total and count are derived during render, not stored separately
- The bug is eliminated without adding synchronization logic
- Tests verify that adding, removing, and updating items always produces the correct total

---

## Scenario 15: Validation Cannot Be Run

**Context**: The agent is working in an environment without a browser, Node.js, or test runner.

**Input**: "Add an accessible tooltip to the info icon in the product card."

**Expected skill behavior**:
- Implements the tooltip with correct ARIA attributes (`role="tooltip"`, `aria-describedby`)
- Ensures keyboard accessibility (visible on focus, dismissible with Escape)
- Explicitly states: "The test runner, browser, and type checker are not available in this environment. The following validations were not run: `tsc --noEmit`, `vitest run`, browser visual verification. Manual testing and CI execution are required before merging."

**Behavior to avoid**:
- Claiming the tooltip is accessible without having verified it
- Refusing to implement the feature because the environment lacks tooling

**Approval criteria**:
- The ARIA implementation is correct based on code analysis
- The response explicitly lists which validations could not be executed
- No false claims of test success or visual verification
