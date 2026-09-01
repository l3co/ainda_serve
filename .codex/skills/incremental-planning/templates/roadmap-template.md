# Implementation Roadmap: {{PROJECT_OR_FEATURE_NAME}}

> **Status:** Planned
> **Created:** {{DATE}}
> **Last updated:** {{DATE}}

---

## Overview

{{Brief description of what this plan covers and why it exists.}}

---

## Goal

{{Single clear statement of what successful completion looks like.}}

---

## Current State

{{Describe the system or situation before this plan is executed. What exists, what is missing, what is broken, or what is about to change.}}

---

## Target State

{{Describe the system after all phases are complete. What will be different, what will now be possible, what will be retired.}}

---

## Success Criteria

- [ ] {{Objective, measurable criterion.}}
- [ ] {{Objective, measurable criterion.}}
- [ ] {{Objective, measurable criterion.}}

---

## Scope

### In Scope

- {{Item explicitly included in this plan.}}
- {{Item explicitly included in this plan.}}

### Out of Scope

- {{Item explicitly excluded. Why it was considered and not included.}}
- {{Item explicitly excluded.}}

### Future Improvements

- {{Recognized improvement deferred to a later plan.}}

---

## Assumptions

| Assumption | Impact if wrong | Status |
|---|---|---|
| {{Assumption declared explicitly.}} | {{What breaks or must change.}} | Unverified |
| {{Assumption declared explicitly.}} | {{What breaks or must change.}} | Unverified |

---

## Constraints

- {{Known constraint: technical, time, resource, regulatory, or organizational.}}
- {{Known constraint.}}

---

## Architecture Summary

{{Brief description of the architectural approach. Reference the architecture document if one exists.}}

Key decisions:
- {{Decision or approach chosen and brief rationale.}}
- {{Decision or approach chosen and brief rationale.}}

---

## Delivery Strategy

{{Describe the incremental delivery approach: vertical slices, horizontal foundation first, risk-first, etc. Explain why this sequence was chosen.}}

---

## Phase Overview

| Phase | Objective | Depends on | Deliverable | Status |
|---|---|---|---|---|
| [Phase 01 — {{PHASE_NAME}}](./phases/phase-01-{{phase-slug}}.md) | {{Objective}} | None | {{Deliverable}} | Planned |
| [Phase 02 — {{PHASE_NAME}}](./phases/phase-02-{{phase-slug}}.md) | {{Objective}} | Phase 01 | {{Deliverable}} | Planned |
| [Phase 03 — {{PHASE_NAME}}](./phases/phase-03-{{phase-slug}}.md) | {{Objective}} | Phase 02 | {{Deliverable}} | Planned |

---

## Critical Path

```
Phase 01 → Phase 02 → Phase 03
```

{{Explanation of why these phases are sequential and what blocks progress at each step.}}

---

## Parallel Work

- {{Work that can proceed alongside another phase, and the condition that makes it safe to parallelize.}}
- {{Or: No parallel work identified in this plan.}}

---

## Dependency Map

### Hard dependencies

- {{Phase N}} requires {{Phase M}} to be complete before it can begin.
- {{Task N.N}} requires {{decision or external item}} to be resolved.

### External dependencies

- {{External system, team, or resource required, and which phase needs it.}}

### Decision dependencies

- {{Decision 001}} must be accepted before {{Phase N}} begins.

---

## Risk Summary

| Risk | Category | Likelihood | Impact | Phase | Mitigation |
|---|---|---|---|---|---|
| {{Risk description}} | {{Category}} | Medium | High | Phase 02 | {{Mitigation strategy}} |

Full risk details: {{link to risks.md if it exists, or document inline for smaller plans}}

---

## Validation Strategy

{{How the overall plan will be validated: what signals indicate successful delivery, how regression will be detected, what monitoring is expected.}}

---

## Rollout Strategy

{{How changes will reach production: all at once, gradual rollout, feature flags, dark launch, etc. Omit for plans that do not affect production.}}

---

## Open Questions

| Question | Affects | Blocking | Owner |
|---|---|---|---|
| {{Question that requires external input or decision.}} | Phase N | Yes / No | {{Person or team}} |
| {{Question.}} | {{Phase or decision.}} | Yes / No | {{Owner}} |

---

## Planning Documents

- [Discovery](./discovery.md) {{— if it exists}}
- [Phase 01 — {{Name}}](./phases/phase-01-{{slug}}.md)
- [Phase 02 — {{Name}}](./phases/phase-02-{{slug}}.md)
- [Phase 03 — {{Name}}](./phases/phase-03-{{slug}}.md)
- [Decision 001 — {{Name}}](./decisions/decision-001-{{slug}}.md) {{— if it exists}}
