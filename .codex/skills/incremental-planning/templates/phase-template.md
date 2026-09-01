# Phase {{PHASE_NUMBER}} — {{PHASE_NAME}}

> **Status:** Planned
> **Phase:** {{PHASE_NUMBER}} of {{TOTAL_PHASES}}

---

## Objective

{{Single clear statement of what this phase delivers and what it makes possible.}}

---

## Value Delivered

{{What becomes possible after this phase is complete. What risk is reduced. What knowledge is gained. What capability is added. How the result can be demonstrated.}}

---

## Scope

### Included

- {{Item explicitly covered by this phase.}}
- {{Item explicitly covered by this phase.}}

### Excluded

- {{Item explicitly not covered by this phase, to prevent scope creep.}}
- {{Item deferred to a later phase — with a reference if possible.}}

---

## Prerequisites

- {{What must be true or complete before this phase can begin.}}
- {{Example: Phase 01 must be complete and all Phase 01 acceptance criteria met.}}

---

## Dependencies

### Hard dependencies

- {{Phase or task that must be complete before this phase can start.}}

### External dependencies

- {{External service, credential, or resource required.}}
- {{Example: Sandbox credentials for the payment provider must be available.}}

### Decision dependencies

- {{Decision that must be accepted before work in this phase begins.}}
- {{Reference: [Decision 001](../decisions/decision-001-{{slug}}.md)}}

---

## Files Involved

| File | Classification | Notes |
|---|---|---|
| `{{path/to/file.ext}}` | Existing file | {{What changes and why.}} |
| `{{path/to/new-file.ext}}` | New file | {{What it will contain.}} |
| `{{path/to/uncertain.ext}}` | Proposed path | {{Needs confirmation before implementation.}} |

---

## Technical Approach

{{Describe the implementation strategy for this phase. What patterns will be used. What the key design decisions are. How this phase fits within the existing architecture. Keep pseudocode minimal and only when it genuinely clarifies the approach.}}

---

## Tasks

### Task {{PHASE_NUMBER}}.1 — {{TASK_NAME}}

**Objective**
{{What specific result this task delivers.}}

**Why**
{{Why this task is necessary at this point in the plan.}}

**Files**
- `{{path/to/file}}`: Existing file — {{what changes}}.
- `{{path/to/new-file}}`: New file — {{what it will contain}}.

**Implementation**
1. {{First concrete step.}}
2. {{Second concrete step.}}
3. {{Third concrete step.}}

**Tests**
- {{Expected test: success scenario.}}
- {{Expected test: error or invalid input scenario.}}
- {{Expected test: relevant edge case.}}

**Validation**
- {{What to run or inspect to confirm this task is complete.}}
- {{Observable outcome that indicates success.}}

**Acceptance criteria**
- [ ] {{Objective, verifiable criterion.}}
- [ ] {{Objective, verifiable criterion.}}

**Risks**
- {{Risk specific to this task}} — {{mitigation.}}

**Dependencies**
- {{Task or phase that must be complete before this task begins. None if independent.}}

---

### Task {{PHASE_NUMBER}}.2 — {{TASK_NAME}}

**Objective**
{{What specific result this task delivers.}}

**Why**
{{Why this task is necessary at this point in the plan.}}

**Files**
- `{{path/to/file}}`: Existing file — {{what changes}}.

**Implementation**
1. {{First concrete step.}}
2. {{Second concrete step.}}

**Tests**
- {{Expected test.}}

**Validation**
- {{What to run or inspect.}}

**Acceptance criteria**
- [ ] {{Criterion.}}

**Risks**
- None identified.

**Dependencies**
- Task {{PHASE_NUMBER}}.1 must be complete.

---

## Testing

{{Describe the testing strategy for this phase as a whole. Which test types apply. What coverage is expected. How tests will be run.}}

---

## Validation

{{Describe how the entire phase will be validated when all tasks are complete. What command, procedure, or evidence confirms the phase is done.}}

Use the test command configured by the project unless specific commands are known.

---

## Acceptance Criteria

- [ ] {{Phase-level criterion: observable behavior that must hold when the phase is complete.}}
- [ ] {{Phase-level criterion.}}
- [ ] {{Phase-level criterion.}}
- [ ] All task-level acceptance criteria above are met.

---

## Risks

| Risk | Category | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| {{Risk description}} | {{Category}} | Low / Medium / High | Low / Medium / High | {{Mitigation strategy}} |

---

## Rollback or Recovery

**Detection:** {{What signal indicates a problem introduced in this phase?}}

**Stop condition:** {{When to halt and revert.}}

**Recovery procedure:**
1. {{Step 1.}}
2. {{Step 2.}}

**Irreversible actions in this phase:**
- {{None, or describe what cannot be undone.}}

**Data at risk:**
- {{None, or describe what data could be affected.}}

---

## Completion Checklist

- [ ] All tasks completed and individually validated
- [ ] Phase acceptance criteria verified
- [ ] Tests executed and results recorded
- [ ] Known issues documented
- [ ] Remaining risks declared
- [ ] Related files updated
- [ ] No mandatory dependency left open
- [ ] Roadmap status updated to reflect completion

---

## Navigation

- [Roadmap](../roadmap.md)
- [Previous phase](./phase-{{PREV_PHASE_NUMBER}}-{{prev-phase-slug}}.md)
- [Next phase](./phase-{{NEXT_PHASE_NUMBER}}-{{next-phase-slug}}.md)
