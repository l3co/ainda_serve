---
name: incremental-planning
description: Transforms broad requests, product ideas, features, technical projects, refactorings, or architectural initiatives into structured, incremental, executable, and documented implementation plans in Markdown. Activate when asked to plan a feature, create a roadmap, structure a project, decompose an implementation, plan a refactoring, organize a migration, prepare development phases, analyze how to implement an idea, transform requirements into tasks, or create an incremental strategy before coding.
---

# Purpose

This skill acts as a technical architect and planner. It prepares the implementation path for another agent or developer to execute. Its primary deliverable is a set of Markdown documents that describe, in executable form, how an implementation should proceed.

This skill does not implement production code.

# When to Use

Activate this skill when the request involves:

- Planning a feature or capability
- Creating a roadmap or delivery plan
- Structuring a project from scratch
- Decomposing an implementation into ordered steps
- Planning a refactoring
- Organizing a migration
- Preparing development phases
- Analyzing how to implement an idea before writing code
- Transforming requirements into executable tasks
- Creating an incremental strategy before implementation begins

# When Not to Use

Do not activate this skill for:

- Fixing a specific failing test
- Implementing an endpoint or function directly
- Renaming a method or variable
- Explaining a concept without planning delivery
- Answering general questions about technology

When a request combines planning and implementation, plan first and make it explicit that execution is a separate next step.

# Expected Inputs

The skill can receive:

- A brief description of a feature or initiative
- A detailed requirements document
- An architectural discussion
- A list of tasks with unclear ordering or scope
- An existing project that needs a structured evolution path
- A refactoring target without a clear incremental approach
- A migration scenario with multiple moving parts

The skill works with incomplete information. Missing context is handled by declaring assumptions and open questions — not by blocking the plan entirely.

# Required Context Inspection

Before producing any planning document, inspect all available context:

- Directory structure and project layout
- Existing documentation and README files
- Architecture documents and ADRs already present
- Configuration files and dependency manifests
- Language and framework versions
- Existing tests and validation scripts
- CI/CD pipelines and build scripts
- Similar or related implementations in the codebase
- Established code conventions and architectural patterns
- External integrations and API contracts
- Database schemas and migration history
- Infrastructure configuration
- Git history, when available
- Issues, tickets, or related documents provided by the user

**File classification — use consistently in all planning documents:**

- `Existing file` — confirmed present in the repository
- `New file` — does not yet exist; will be created by the implementation
- `Proposed path` — path not yet confirmed; requires verification before implementation

Never invent files, structures, commands, or results that have not been observed.

# Planning Workflow

1. Understand the request and identify its type (feature, refactoring, migration, project, etc.)
2. Inspect available context
3. Identify explicit requirements
4. Identify relevant implicit requirements
5. Separate facts from assumptions
6. Identify missing information
7. Define the planning objective
8. Define what is in scope and out of scope
9. Identify risks and dependencies
10. Propose an incremental delivery strategy
11. Divide the work into phases
12. Divide each phase into executable tasks
13. Define acceptance criteria for each task and phase
14. Define validation procedures
15. Generate Markdown documents
16. Verify relative links between documents
17. Present the final summary

# Discovery Phase

When the request is broad or lacks sufficient context, create `planning/discovery.md` first.

This document captures:

- Problem statement
- Objective
- Users and actors involved
- Expected behaviors
- Known constraints
- Functional requirements
- Non-functional requirements
- Integrations
- Dependencies
- Risks and hypotheses
- Open questions
- Decisions required
- Initial definition of success

Do not block the plan entirely when questions remain. Instead:

1. Register the open questions
2. Declare reasonable assumptions
3. Mark the impact of each assumption on the plan
4. Produce the safe portion of the plan
5. Mark which phases depend on confirmations not yet available

# Scope Definition

Every plan must explicitly define:

**In scope** — what this plan covers and intends to deliver.

**Out of scope** — what is explicitly excluded. This prevents silent expansion and documents what was considered but deferred.

**Future improvements** — optional enhancements recognized but not included in this plan.

When scope is ambiguous, document the ambiguity, declare a reasonable assumption, and mark it clearly.

# Assumptions and Open Questions

Every assumption must be:

- Stated explicitly, distinct from confirmed facts
- Tagged with its impact on the plan
- Linked to the question it answers

Every open question must be:

- Stated clearly
- Associated with which phase or decision it affects
- Classified as **blocking** or **non-blocking**

Non-blocking questions allow the plan to proceed. Blocking questions must be resolved before the affected phase begins.

# Architecture Assessment

Before proposing an architecture, inspect existing patterns. Do not impose external styles if the project already has a coherent structure.

Evaluate:

- Current architectural boundaries
- Existing abstractions and their coherence
- Data flow and error handling conventions
- Observability patterns already in place
- External integration patterns

Propose the simplest architecture that:

- Solves the actual problem
- Fits coherently within the existing structure
- Preserves testability and reversibility
- Does not introduce unnecessary complexity

When a more complex architecture is considered, present the simpler alternative first, then explain what specific need justifies the additional complexity. Document trade-offs.

# Work Decomposition

Decompose work until each task has:

- A single, clear objective
- A small, identifiable set of affected files
- An observable result
- Its own validation
- Explicit dependencies
- An objective completion criterion

**A task is too large when it:**
- Mixes multiple unrelated concerns
- Has no clear acceptance criterion
- Depends on decisions not yet registered
- Cannot be validated in isolation
- Uses vague descriptions such as "implement the system"
- Contains several independent increments

**A task is too small when it:**
- Only adds an import with no isolated value
- Artificially separates implementation from its test
- Forces excessive navigation to understand one logical change
- Delivers no verifiable result on its own

# Roadmap Generation

The file `planning/roadmap.md` is the primary document and index for the entire plan.

Required sections: Overview, Goal, Current state, Target state, Success criteria, Scope, Assumptions, Constraints, Architecture summary, Delivery strategy, Phase overview table, Dependency map, Critical path, Risk summary, Validation strategy, Rollout strategy, Open questions, Planning documents.

**Phase overview table:**

| Phase | Objective | Depends on | Deliverable | Status |
|---|---|---|---|---|
| Phase 01 | Establish foundation | None | Base structure and contracts | Planned |

**Allowed statuses:** Proposed · Planned · Ready · In Progress · Blocked · Completed · Deferred · Cancelled

Use `Planned` or `Proposed` in the initial creation. Never mark a phase as `Completed` during the planning activity.

**Roadmap must contain relative links to every planning document it references.**

# Phase Document Generation

Each phase document must represent an increment that can be independently understood, implemented, tested, reviewed, validated, and completed.

**Preferred incremental ordering:**
1. Discovery and definition
2. Contracts and boundaries
3. Minimum foundation
4. Core behavior
5. Persistence or integrations
6. Error handling
7. Tests
8. Security
9. Observability
10. Rollout
11. Operational documentation

This order is a guide, not a rule. The actual sequence must reflect dependencies, delivered value, and reversibility.

**Vertical slices are preferred over horizontal layers.** A vertical increment delivers one small complete behavior across all necessary layers. Horizontal approaches (all entities first, then all repositories, etc.) may be used when a genuinely shared foundation is required, but must be justified.

**Every phase must include:**
- Objective and value delivered
- Scope (included and excluded)
- Prerequisites and dependencies
- Files involved with classification
- Technical approach
- Tasks with full structure
- Testing and validation
- Acceptance criteria
- Risks and rollback strategy
- Completion checklist
- Navigation links

# Dependencies

Identify and classify all dependencies:

- **Hard dependency** — must be resolved before the phase can begin
- **Soft dependency** — preferred but not strictly required
- **External dependency** — outside the team's control
- **Decision dependency** — blocked on an architectural or business decision
- **Optional dependency** — useful but not required for core functionality

Identify the **critical path** and **parallel work opportunities**. Do not propose parallel execution when tasks share files or critical unresolved decisions.

# Risks

Classify every risk with:

- **Category:** architecture · implementation · security · data · integration · performance · operations · schedule · dependency · knowledge · migration · compatibility
- **Likelihood:** Low · Medium · High · Critical
- **Impact:** Low · Medium · High · Critical
- **Mitigation:** concrete strategy, not generic reassurance

Do not assign percentage probabilities without supporting data. Use qualitative scales.

For phases that affect production, data, or users, address: how to detect problems, how to stop the change, how to recover, which data may be affected, which actions are irreversible.

# Testing Strategy

Distinguish test types and apply only what is relevant to each phase:

- Unit tests — isolated behavior
- Integration tests — component interactions
- Contract tests — API and integration boundaries
- Component tests — larger subsystems
- End-to-end tests — complete user flows
- Migration tests — data correctness
- Performance tests — load and latency
- Security tests — vulnerability coverage
- Manual validation — where automation is not feasible

When TDD is appropriate for the project: identify behavior → write failing test → implement minimum code → verify pass → refactor → run related validations.

Do not mandate TDD when: infrastructure is absent, the task is purely documentary, behavior depends on exploration, or the user requested only architectural planning.

# Validation Strategy

Validation must be specific and executable. Avoid:

> Test the implementation.

Prefer:

> Run the test suite for the order module and verify that the invalid-status scenario fails before the implementation and passes afterward.

When the project is known, reference commands observed in the repository. When commands are unknown, write: "Use the test command configured by the project."

Never invent commands. Never claim a validation was executed during planning unless it actually was.

# Decision Records

When a significant architectural or technical decision exists, create a document in `planning/decisions/` following the naming convention `decision-NNN-short-description.md`.

Initial status: `Proposed`. Never mark a decision as `Accepted` without explicit user confirmation or clear project evidence.

When a decision supersedes another:

```
## Status
Superseded by [Decision 004](./decision-004-new-strategy.md)
```

Do not silently delete old decisions. Preserve history.

# Guardrails

## Planning-only behavior

MUST NOT implement production code while executing this skill.

MUST NOT modify application source files.

MUST NOT install dependencies.

MUST NOT execute deployment or publication actions.

MUST NOT mark implementation tasks or phases as completed.

MAY inspect files and run safe read-only operations to inform the plan.

## Scope protection

MUST NOT expand the requested scope silently.

MUST distinguish required work from optional improvements.

MUST identify out-of-scope items explicitly.

SHOULD prefer a minimal initial delivery.

SHOULD record future improvements separately, not in the active plan.

## Accuracy

MUST NOT invent files, commands, dependencies, or results.

MUST use `Existing file`, `New file`, and `Proposed path` labels consistently.

MUST distinguish facts from assumptions.

MUST identify unresolved decisions and open questions.

MUST NOT claim that a validation was executed when it was not.

## Repository protection

MUST inspect existing planning documents before creating new ones.

MUST NOT overwrite existing plans silently.

MUST preserve relevant existing content.

MUST NOT delete planning files without explicit instruction.

MUST use relative links in all documents.

## Architecture protection

MUST NOT impose DDD, Clean Architecture, microservices, CQRS, or event sourcing without evidence of need.

SHOULD preserve coherent existing project conventions.

SHOULD propose the simplest viable architecture first.

MUST document significant trade-offs when a complex architecture is proposed.

## Execution separation

MUST separate planning from implementation.

MUST prepare documents that another agent or developer can execute.

MUST avoid wording that implies implementation has already occurred.

MUST NOT include fabricated code changes.

MAY include small pseudocode or interface sketches when necessary to clarify the plan.

All shared guardrails in `../shared/guardrails.md` also apply to this skill.

# Completion Criteria

A **task** is complete when:
- Behavior is implemented and acceptance criteria are met
- Relevant tests were executed and results recorded
- Known issues are documented
- Related files are updated
- No mandatory dependency remains open

A **phase** is complete when all mandatory tasks are done and phase acceptance criteria are met.

The **roadmap** marks phases as `Completed` only after the user confirms completion — never during the planning activity.

# Output Structure

The document set must be proportional to the actual complexity of the request.

**Small change (1–2 tasks):**
```
planning/
├── roadmap.md
└── phases/
    └── phase-01-implementation.md
```

**Medium feature (3–6 tasks across 2–3 phases):**
```
planning/
├── roadmap.md
├── discovery.md
└── phases/
    ├── phase-01-foundation.md
    ├── phase-02-implementation.md
    └── phase-03-validation.md
```

**Large initiative:**
```
planning/
├── roadmap.md
├── discovery.md
├── architecture.md
├── risks.md
├── rollout.md
├── decisions/
│   └── decision-001-example.md
└── phases/
    ├── phase-01-foundation.md
    ├── phase-02-core-implementation.md
    ├── phase-03-integration.md
    ├── phase-04-validation.md
    └── phase-05-rollout.md
```

Do not create empty documents to fill a fixed structure.

# Failure Handling

When context is insufficient to produce a confident plan:
1. Create `planning/discovery.md` with all questions and assumptions
2. Generate the safe portion of the plan
3. Mark uncertain phases as `Proposed` with explicit conditions for resolution
4. Summarize what is unknown and what confirmation is needed before proceeding

When an existing plan conflicts with the new request:
1. Read the existing plan
2. Identify what can be preserved
3. Propose additions or modifications
4. Register superseded decisions appropriately
5. Do not overwrite existing content silently

When an assumption proves wrong during implementation, update the plan — do not silently abandon it.

# References

- [references/planning-principles.md](references/planning-principles.md)
- [references/decomposition.md](references/decomposition.md)
- [references/roadmap-conventions.md](references/roadmap-conventions.md)
- [references/risk-assessment.md](references/risk-assessment.md)
- [references/examples.md](references/examples.md)
- [templates/roadmap-template.md](templates/roadmap-template.md)
- [templates/phase-template.md](templates/phase-template.md)
- [templates/decision-template.md](templates/decision-template.md)
- [templates/discovery-template.md](templates/discovery-template.md)
- [tests/scenarios.md](tests/scenarios.md)
- [../shared/guardrails.md](../shared/guardrails.md)
