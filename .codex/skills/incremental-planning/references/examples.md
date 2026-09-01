# Planning Examples

Brief reference examples. Not complete plans — they illustrate the right level of structure for different sizes of work.

---

## Example 1 — Small Change

**Request:** "Plan the addition of a validation rule to the user registration endpoint: password must contain at least one digit."

**Appropriate output:**

```
planning/
├── roadmap.md
└── phases/
    └── phase-01-password-digit-validation.md
```

**roadmap.md (excerpt):**

```markdown
## Goal
Add a validation rule requiring at least one digit in passwords during user registration.

## Phase overview
| Phase | Objective | Depends on | Deliverable | Status |
|---|---|---|---|---|
| Phase 01 | Add digit validation | None | Validated registration endpoint | Planned |

## Planning documents
- [Phase 01 — Password Digit Validation](./phases/phase-01-password-digit-validation.md)
```

**phase-01 (excerpt):**

```markdown
### Task 1.1 — Add digit requirement to registration validation

**Files**
- `src/accounts/user.ex`: Existing file — add `validate_format(:password, ...)` rule for digit presence.
- `test/accounts/user_test.exs`: Existing file — add test cases for missing and present digit.

**Acceptance criteria**
- [ ] Registration with no digit in password returns a documented error.
- [ ] Registration with a digit in password proceeds normally.
- [ ] Existing tests continue to pass.
```

No discovery document. No risk matrix. No architecture document. The change is simple and self-contained.

---

## Example 2 — Medium Feature

**Request:** "Plan the implementation of a product search endpoint with filters for category, price range, and availability."

**Appropriate output:**

```
planning/
├── roadmap.md
├── discovery.md
└── phases/
    ├── phase-01-api-contract.md
    ├── phase-02-query-implementation.md
    └── phase-03-validation.md
```

**Key decisions captured:**
- Whether to use full-text search or SQL LIKE (Decision 001)
- Whether to support pagination in the first version or defer it

**Phase 01 — API Contract:**
Define request schema, response schema, filter parameters, error responses. No implementation yet.

**Phase 02 — Query Implementation:**
Implement the database query with filters, using the contract defined in Phase 01.

**Phase 03 — Validation:**
End-to-end test covering filter combinations, empty results, invalid inputs, and boundary values.

**Observations:**
- Three phases because the contract, implementation, and validation have different validation mechanisms
- No microservices, no event sourcing — a composable query function is sufficient
- Pagination deferred — documented in Out of scope

---

## Example 3 — Database Migration

**Request:** "Plan the migration of the `users` table to split the `name` column into `first_name` and `last_name`."

**Appropriate output:**

```
planning/
├── roadmap.md
├── discovery.md
├── decisions/
│   └── decision-001-migration-strategy.md
└── phases/
    ├── phase-01-additive-schema.md
    ├── phase-02-dual-write.md
    ├── phase-03-backfill.md
    ├── phase-04-read-migration.md
    └── phase-05-column-removal.md
```

**Phase strategy (additive migration):**

| Phase | Action | Reversible |
|---|---|---|
| Phase 01 | Add `first_name` and `last_name` columns (nullable) | Yes |
| Phase 02 | Write to old and new columns simultaneously | Yes |
| Phase 03 | Backfill new columns from existing `name` data | Yes |
| Phase 04 | Switch reads to new columns; verify | Yes |
| Phase 05 | Remove `name` column after stabilization period | **No — requires confirmed rollback** |

**Key risk:** Phase 05 is irreversible. It has its own rollback protocol and a stabilization period before execution.

**Decision 001** documents why the additive approach was chosen over a single destructive migration.

---

## Example 4 — Refactoring

**Request:** "Plan the refactoring of the `OrderService` class, which currently handles pricing, inventory reservation, and notification in a single method."

**Appropriate output:**

```
planning/
├── roadmap.md
└── phases/
    ├── phase-01-characterization-tests.md
    ├── phase-02-extract-pricing.md
    ├── phase-03-extract-inventory.md
    └── phase-04-extract-notification.md
```

**Phase 01 — Characterization tests:**
Write tests that capture the current behavior before changing anything. This is the safety net for the refactoring.

**Phases 02–04 — Incremental extractions:**
Each extraction is a separate phase. After each extraction, all existing tests pass. No behavior changes — only structure changes.

**Key principle:** Behavior-preserving refactoring. Each phase ends with all tests green and behavior identical to the original.

---

## Example 5 — External Integration

**Request:** "Plan the integration with a third-party SMS provider for two-factor authentication."

**Appropriate output:**

```
planning/
├── roadmap.md
├── discovery.md
├── decisions/
│   └── decision-001-sms-provider-choice.md
└── phases/
    ├── phase-01-interface-and-fake.md
    ├── phase-02-core-2fa-logic.md
    ├── phase-03-provider-integration.md
    └── phase-04-end-to-end-validation.md
```

**Phase 01 — Interface and fake sender:**
Define the SMS sender interface. Implement a fake that records calls. All 2FA logic is tested against the fake.

**Phase 02 — Core 2FA logic:**
Implement token generation, expiry, and verification using the fake sender.

**Phase 03 — Real provider integration:**
Replace the fake with the real provider client. Verify against the sandbox environment.

**Phase 04 — End-to-end validation:**
Full flow test: request code → receive SMS (sandbox) → submit code → authentication succeeds.

**External dependency noted:** Phase 03 requires sandbox credentials. If unavailable, Phase 03 is blocked. Phase 02 can proceed independently.

---

## Example 6 — Rich Domain Project

**Request:** "Plan the implementation of an order management module with products, pricing rules, inventory, and order lifecycle."

**Appropriate output:**

```
planning/
├── roadmap.md
├── discovery.md
├── architecture.md
├── decisions/
│   ├── decision-001-aggregate-boundaries.md
│   └── decision-002-pricing-model.md
└── phases/
    ├── phase-01-domain-model.md
    ├── phase-02-pricing-rules.md
    ├── phase-03-inventory-reservation.md
    ├── phase-04-order-placement.md
    ├── phase-05-persistence.md
    ├── phase-06-api-layer.md
    └── phase-07-observability.md
```

**Discovery.md** captures open questions about which bounded contexts exist and what the aggregate boundaries should be.

**Architecture.md** documents the module structure, layer responsibilities, and how this module interacts with the rest of the system.

**Decisions** capture the most important architectural choices before implementation begins.

---

## Example 7 — Over-Engineered Plan (Avoid)

**Request:** "Plan the addition of a log statement to the payment processing function."

**Over-engineered response (do not do this):**

```
planning/
├── roadmap.md
├── discovery.md
├── architecture.md
├── risks.md
├── rollout.md
├── decisions/
│   ├── decision-001-logging-library.md
│   ├── decision-002-log-level-strategy.md
│   └── decision-003-observability-approach.md
└── phases/
    ├── phase-01-logging-foundation.md
    ├── phase-02-log-statement.md
    ├── phase-03-validation.md
    ├── phase-04-monitoring.md
    └── phase-05-rollout.md
```

This is disproportionate. The change is trivial. The structure adds more complexity than the problem warrants.

---

## Example 8 — Simplified Version of Example 7

**Appropriate response for adding a log statement:**

```
planning/
└── roadmap.md
```

**roadmap.md (excerpt):**

```markdown
## Goal
Add a structured log entry to the `process_payment/1` function to record the payment attempt ID and outcome.

## Scope
### In scope
- One log statement at the entry point of the payment function
- One log statement for the success path
- One log statement for the error path

### Out of scope
- Centralized logging infrastructure changes
- Distributed tracing
- Metrics or dashboards

## Tasks
- [ ] Add `Logger.info("payment attempt", payment_id: id)` at function entry
- [ ] Add `Logger.info("payment succeeded", payment_id: id)` on success
- [ ] Add `Logger.error("payment failed", payment_id: id, reason: reason)` on error
- [ ] Verify no credentials or PII appear in the log entries
```

No phases, no discovery, no ADRs. The task fits in a single short document.
