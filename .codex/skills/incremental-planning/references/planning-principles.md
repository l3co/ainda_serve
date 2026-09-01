# Planning Principles

These principles guide how this skill approaches every planning activity. They are not rigid rules — they are lenses that help produce plans that are honest, executable, and proportional to the actual problem.

---

## A Plan Is a Hypothesis

A plan is a structured hypothesis about how to reach an objective — not a guarantee that no discoveries will occur during implementation.

The plan must be revisable. When implementation reveals that an assumption was wrong, the plan is updated — not silently abandoned.

The goal is not a perfect plan. The goal is a plan that reduces uncertainty, orders work sensibly, and enables confident execution.

---

## Incremental Delivery

Break work into increments that can each be:

- Implemented
- Tested
- Validated
- Reviewed
- Delivered or merged independently

An increment that cannot be verified in isolation is not an increment — it is a fragment. Avoid fragments.

An increment that attempts too much is not a phase — it is a project. Avoid premature completeness.

---

## Value-Oriented Sequencing

Order increments by the value they deliver and the risk they reduce, not by technical convenience.

Prefer increments that:

- Deliver a behavior users or systems can observe
- Reduce the highest-risk unknowns early
- Establish stable foundations before building on them
- Enable feedback before investing further

Avoid starting with infrastructure that serves no behavior yet.

---

## Progressive Risk Reduction

Place the riskiest, least certain work early — not late.

A plan that defers all risky work to the final phase does not reduce risk; it accumulates it.

When a phase introduces high risk, the plan must describe:

- How to detect problems
- How to stop the change
- How to recover the previous state
- What data may be affected
- Which actions are irreversible

---

## Reversible Decisions First

Prefer reversible decisions when confidence is low.

Classify every significant decision as:

- **Reversible** — can be changed with reasonable cost
- **Partially reversible** — can be changed but with effort and potential side effects
- **Irreversible** — cannot be undone once taken (data deletion, public API removal, infrastructure destruction)

Irreversible decisions require the most deliberation. Document the reasoning explicitly.

---

## Evidence-Based Planning

Base every planning decision on evidence from the project:

- Existing code, patterns, and conventions
- Known constraints
- Observed dependencies
- Historical problems

When evidence is absent, declare an assumption. When evidence is contradictory, document the conflict and choose explicitly.

Do not invent evidence. Do not assume a project structure without observing it.

---

## Simplicity

Start with the minimum viable design. Introduce complexity only when the actual problem requires it.

**YAGNI — You Aren't Gonna Need It**

Do not plan for features that might be useful in the future. Plan for the actual requirement at hand.

YAGNI applies to: generic abstractions, extension points, plugin systems, internal frameworks, event sourcing, CQRS, microservices, additional databases, and observability layers beyond what is needed.

**KISS — Keep It Simple**

Prefer explicit, readable solutions over clever, compact ones. A plan that requires extensive commentary to understand is already too complex.

**DRY — Don't Repeat Yourself**

Avoid duplicating knowledge or intent across the plan. One decision, one source. But do not create premature abstractions to remove small surface similarities.

**SOLID — Applied Pragmatically**

Apply SOLID principles where object-oriented design is involved and where they genuinely reduce coupling or increase cohesion. Do not apply them as a checklist.

---

## Vertical Slices

When decomposing work, prefer vertical slices over horizontal layers.

A **vertical slice** delivers one small, complete behavior through all layers necessary to make it work:

```
Receive request → validate input → execute use case → persist result → return response → test behavior
```

A **horizontal approach** builds one layer across all behaviors before moving to the next:

```
Create all entities → create all repositories → create all services → create all controllers → add all tests
```

Prefer vertical slices because:

- Each slice delivers observable value
- Integration problems surface earlier
- Partial delivery is possible
- Risk is distributed across increments

Use horizontal approaches only when a shared foundation is genuinely required before any behavior can be implemented — and justify this choice.

---

## Fast Feedback

Design increments so that feedback is available as early as possible.

Feedback comes from:

- Tests that verify behavior
- Builds that confirm syntax and compilation
- Linters that enforce conventions
- Reviews that catch design problems
- Users or systems that interact with behavior

A phase with no feedback mechanism is a blind step. Every phase must define how its outcome will be verified.

---

## Testing as Verification, Not as Afterthought

Tests are how a plan's completion criteria become verifiable.

Every task must answer: how will we know this is done?

Testing is not a separate phase at the end. It is embedded in each task, each phase, and each increment.

Types of testing are chosen based on what provides the most confidence at the lowest cost at each stage.

---

## Proportional Documentation

Documentation must be proportional to the complexity and risk of the change.

A trivial validation change does not need an architecture document, five ADRs, and a risk matrix.

A framework migration does.

Produce documentation that:

- A developer could execute without asking clarifying questions
- Survives the person who wrote it leaving
- Fits the actual complexity of the work

Avoid documentation that:

- Repeats what is already clear from the code
- Exists to fill a structural template
- Describes intent without describing how to verify it

---

## Gradual Rollout

When a change affects production systems, data, or users, design the rollout as an incremental process.

Techniques to consider:

- **Feature flags** — control visibility without code deployment
- **Dual write** — write to old and new systems simultaneously during migration
- **Dual read** — read from both until confidence is established
- **Backfill** — populate new structures from existing data before switching
- **Dark launch** — execute new logic without exposing the result
- **Canary deployment** — expose change to a small portion first
- **Stabilization period** — monitor before expanding rollout
- **Rollback plan** — clear procedure to revert if monitoring signals problems

Do not use these techniques mechanically. Use them when the risk justifies the complexity.

---

## Explicit Assumptions and Questions

A plan without assumptions is either complete or dishonest.

Assumptions allow planning to proceed despite uncertainty. They must be:

- Stated explicitly
- Distinguished from facts
- Tied to an impact assessment
- Revisited when evidence changes

Open questions are not failures. They are honest acknowledgments of what is not yet known. Classify each as blocking or non-blocking.
