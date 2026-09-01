# Discovery: {{TOPIC_OR_FEATURE_NAME}}

> **Status:** In progress
> **Created:** {{DATE}}
> **Purpose:** Capture context, questions, and assumptions before planning begins

This document records what is known, what is assumed, and what must be confirmed before the implementation plan can be completed. It is a working document — update it as new information becomes available.

---

## Problem Statement

{{Describe the problem this initiative addresses. Be concrete. What is currently broken, missing, inefficient, or painful? Who experiences this problem? How often? What is the cost of not solving it?}}

---

## Objective

{{What does success look like? What will be different when this is complete? Try to state this in terms of observable outcomes, not deliverables.}}

---

## Users and Actors

| Actor | Role | Need |
|---|---|---|
| {{Actor}} | {{Their role in the system}} | {{What they need from this initiative}} |
| {{Actor}} | {{Role}} | {{Need}} |

---

## Expected Behaviors

{{List the behaviors the system must exhibit after this initiative is complete. Write these as observable outcomes, not implementation details.}}

- {{Behavior: what the system does, under what condition, with what result.}}
- {{Behavior.}}
- {{Behavior.}}

---

## Known Constraints

{{Document constraints that are fixed and cannot be changed: technical, regulatory, organizational, budget, timeline, or compatibility.}}

- {{Constraint: what it is and why it cannot be changed.}}
- {{Constraint.}}

---

## Functional Requirements

{{What must the system be able to do? Use "must" for required and "should" for strongly preferred.}}

- The system must {{requirement}}.
- The system must {{requirement}}.
- The system should {{requirement}}.

---

## Non-Functional Requirements

| Requirement | Target | Notes |
|---|---|---|
| Performance | {{e.g., p99 < 300ms for the search endpoint}} | {{Context}} |
| Availability | {{e.g., same SLA as the existing service}} | {{Context}} |
| Security | {{e.g., no PII in logs}} | {{Context}} |
| Scalability | {{e.g., support 10x current load without redesign}} | {{Context}} |
| Compatibility | {{e.g., existing API consumers must not be broken}} | {{Context}} |

---

## Integrations

{{Which external systems, services, or teams does this initiative interact with?}}

| System | Direction | Current state | Notes |
|---|---|---|---|
| {{System name}} | Inbound / Outbound / Both | Existing / New | {{Relevant details}} |
| {{System name}} | {{Direction}} | {{State}} | {{Notes}} |

---

## Dependencies

{{What must exist, be completed, or be decided before this initiative can proceed?}}

| Dependency | Type | Status | Owner |
|---|---|---|---|
| {{Dependency}} | Technical / Decision / Human / External | Available / Pending / Blocked | {{Owner}} |
| {{Dependency}} | {{Type}} | {{Status}} | {{Owner}} |

---

## Risks and Hypotheses

{{What could go wrong? What are the highest-uncertainty areas?}}

| Risk or hypothesis | Likelihood | Impact | How to validate |
|---|---|---|---|
| {{Risk or hypothesis}} | Low / Medium / High | Low / Medium / High | {{How to confirm or refute}} |
| {{Risk or hypothesis}} | {{}} | {{}} | {{}} |

---

## Open Questions

{{What is not yet known and must be answered before planning or implementation can proceed?}}

| Question | Affects | Blocking | Owner |
|---|---|---|---|
| {{Question}} | {{Area of the plan it affects}} | Yes / No | {{Person or team}} |
| {{Question}} | {{Area}} | Yes / No | {{Owner}} |

---

## Decisions Required

{{Which architectural, technical, or product decisions must be made before or during planning?}}

- [ ] {{Decision to be made — reference a decision document if started.}}
- [ ] {{Decision to be made.}}

---

## Declared Assumptions

{{List all assumptions being made to allow planning to proceed. Mark each one's impact and how it will be validated.}}

| Assumption | Impact if wrong | How to validate |
|---|---|---|
| {{Assumption}} | {{What breaks or changes}} | {{How to confirm}} |
| {{Assumption}} | {{Impact}} | {{Validation}} |

---

## Initial Definition of Success

{{How will we know when this initiative is complete and successful? Be specific enough that this could serve as the basis for phase-level acceptance criteria.}}

- [ ] {{Objective, observable criterion.}}
- [ ] {{Criterion.}}
- [ ] {{Criterion.}}

---

## Context Inspection Summary

{{Document what was found when inspecting the existing project — relevant files, patterns, conventions, or constraints discovered during context inspection.}}

| Finding | Source | Implication |
|---|---|---|
| {{Finding}} | {{File or observation}} | {{What it means for the plan}} |
| {{Finding}} | {{Source}} | {{Implication}} |

---

## Next Steps

- [ ] Resolve blocking open questions before Phase 01 begins
- [ ] Confirm assumptions listed above
- [ ] Create `planning/roadmap.md` based on this discovery
- [ ] {{Other specific next step.}}
