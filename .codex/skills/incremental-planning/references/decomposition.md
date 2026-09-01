# Work Decomposition

Decomposition is the process of transforming a broad objective into a sequence of small, cohesive, executable, and verifiable units of work.

Good decomposition does not just break a problem into smaller pieces — it breaks it in ways that optimize for delivery order, risk reduction, verifiability, and independent value.

---

## Decomposition Approaches

Choose the approach that best fits the nature of the work. Combine when necessary.

### By Value (User-Facing Behavior)

Slice work by the observable behaviors that users or systems will experience. Each slice makes something new possible.

Best for: feature development, product increments, API changes.

```
Slice 1 — Register with email and password
Slice 2 — Log in and receive a session token
Slice 3 — Reset password via email
Slice 4 — Update profile
```

### By User Flow

Follow the path a user takes through the system. Each step corresponds to a meaningful user action.

Best for: workflows, multi-step processes, forms, wizards.

```
Step 1 — User submits order items
Step 2 — System validates and prices the order
Step 3 — User confirms and pays
Step 4 — System confirms and sends receipt
```

### By Domain Concept

Decompose around the core domain concepts and their behaviors, starting with the most fundamental.

Best for: domain-rich systems, DDD contexts.

```
Task 1 — Define the Order aggregate and its invariants
Task 2 — Implement order placement
Task 3 — Implement order cancellation
Task 4 — Implement order fulfillment
```

### By Risk

Tackle the most uncertain or risky elements first to reduce uncertainty early.

Best for: migrations, integrations with unknown APIs, performance-sensitive paths.

```
Phase 1 — Verify that the external payment API behaves as documented (spike)
Phase 2 — Implement the happy-path integration
Phase 3 — Implement error handling and retries
Phase 4 — Load test the integration path
```

### By Dependency

Order work so that foundational elements are available before dependent work begins.

Best for: new projects, platform changes, shared infrastructure.

```
Phase 1 — Define data schemas and API contracts
Phase 2 — Implement core business logic
Phase 3 — Connect persistence layer
Phase 4 — Expose API endpoints
Phase 5 — Add client-side consumption
```

### By Integration

Isolate integration work from core behavior. Implement internal behavior with fakes or stubs first, then replace with real integrations.

Best for: external APIs, message brokers, payment gateways, notification services.

```
Phase 1 — Implement behavior with a fake notification sender
Phase 2 — Define the notification sender interface
Phase 3 — Implement the real email sender
Phase 4 — Verify end-to-end with the real provider
```

### By Component

Decompose by system components when they have clear boundaries and limited coupling.

Best for: multi-system initiatives, platform migrations, UI + API work.

```
Component A — Backend API contract (parallel track)
Component B — Frontend integration (parallel track)
Component C — Database migration (sequential, required first)
```

### By Data

Decompose migrations or transformations by data category, volume, or risk.

Best for: database migrations, data model changes, schema evolution.

```
Phase 1 — Add new columns without removing old ones
Phase 2 — Backfill new columns from existing data
Phase 3 — Migrate application to read from new columns
Phase 4 — Remove old columns after stabilization
```

### By Rollout

Decompose based on how the change will reach production.

Best for: high-risk changes, public APIs, large user bases.

```
Phase 1 — Implement behind a feature flag
Phase 2 — Enable for internal users
Phase 3 — Gradual rollout (10% → 50% → 100%)
Phase 4 — Remove the feature flag
```

### By Layer

Decompose by architectural layer when a shared foundation is genuinely required.

Best for: framework setup, platform changes, cross-cutting infrastructure.

Use only when no behavior can be delivered without the layer being complete first. Justify the horizontal approach explicitly.

```
Layer 1 — Configure the web framework and routing
Layer 2 — Configure the ORM and schema
Layer 3 — Implement the first vertical slice
```

---

## Granularity Guide

A well-decomposed task:

- Has a single, clear objective
- Affects a small, identifiable set of files
- Delivers an observable result
- Has its own validation
- Has explicit dependencies
- Has an objective completion criterion
- Can be implemented in one focused session

**Too large — signs:**
- Description says "implement X system"
- No clear acceptance criterion
- Touches unrelated files or modules
- Cannot be independently tested
- Contains the word "everything"

**Too small — signs:**
- Only adds an import statement
- Changes one line without isolated value
- Separates implementation and its test for no reason
- Requires reading 10 adjacent tasks to understand the change
- Delivers nothing observable

---

## Poor vs. Good Decomposition

### Poor decomposition — horizontal, vague

```
Task 1 — Build the backend
Task 2 — Build the frontend
Task 3 — Add tests
Task 4 — Deploy
```

Problems:
- No observable result at any intermediate step
- No dependencies documented
- No acceptance criteria possible
- Cannot be validated independently

### Good decomposition — vertical, specific

```
Task 1 — Define the registration API contract (request schema, response schema, error codes)
Task 2 — Implement email format validation and return documented error
Task 3 — Hash password and persist a valid registration
Task 4 — Return validation errors in the documented format
Task 5 — Display registration feedback in the form
Task 6 — Verify the complete registration flow end-to-end
```

Each task:
- Has a single objective
- Can be verified independently
- Connects to the next through a clear dependency
- Delivers an observable result

---

## Dependency Mapping

Before finalizing task order, map dependencies explicitly:

```
Task 1.1 (API contract) ← no dependencies
Task 1.2 (validation) ← depends on 1.1 (contract must define error format)
Task 1.3 (persistence) ← depends on 1.1 (contract defines schema)
Task 1.4 (error response) ← depends on 1.2 and 1.1
Task 1.5 (frontend form) ← depends on 1.4 (needs final error format)
Task 1.6 (end-to-end) ← depends on all above
```

When two tasks have no dependency between them, they may be candidates for parallel work — but only when they do not share files or depend on unresolved decisions.

---

## Splitting a Large Task

When a task is too large, split it by:

1. **Separating contract from implementation** — define the interface before implementing it
2. **Separating the happy path from error handling** — deliver the successful scenario first
3. **Separating implementation from validation** — implement the behavior, then add its test
4. **Separating layers** — only when layers are genuinely independent
5. **Extracting the foundational piece** — identify the prerequisite and make it its own task

When a task cannot be reasonably split and is still too large, it may belong in its own phase.

---

## When to Stop Decomposing

Stop decomposing when each piece:

- Can be understood without reading adjacent tasks
- Can be implemented in one focused session
- Has a clear completion criterion
- Can be validated independently
- Does not internally contain multiple unrelated objectives

Further decomposition beyond this point produces noise, not clarity.
