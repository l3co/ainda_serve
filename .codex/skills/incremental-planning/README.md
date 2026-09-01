# Incremental Planning Skill

## Purpose

This skill transforms broad requests, product ideas, features, technical projects, refactorings, or architectural initiatives into structured, incremental, and executable implementation plans documented in Markdown.

It acts as a technical architect and planner — preparing the path for another agent or developer to implement. It does not write production code.

## How to Install

Place this skill directory in the Skills location recognized by your agent:

- **Claude Code:** reference `SKILL.md` from your project's `CLAUDE.md` using an `@` import
- **Codex:** add a reference to `AGENTS.md` in the project root
- **Gemini CLI:** add a reference to `GEMINI.md` in the project root
- **Other agents:** follow the agent's skill discovery mechanism

## How to Activate

This skill activates when the request involves planning, decomposition, or roadmap creation — not direct implementation.

**Activate for:**

```
Plan the implementation of OAuth authentication.
Create an incremental roadmap for migrating this service to Go.
Break this feature into executable implementation phases.
Prepare a technical plan for adding payment processing.
Create a roadmap before we implement this refactoring.
Decompose this migration into ordered, testable steps.
Structure this project from scratch before any code is written.
Analyze how we should implement this and what the risks are.
```

**Do not activate for:**

```
Fix this failing test.
Implement the endpoint.
Rename this method.
Explain what dependency injection is.
Add a log statement here.
```

When a request combines planning and implementation, this skill plans first and makes it explicit that execution is a separate next step.

## Supported Planning Types

| Type | Description |
|---|---|
| Feature planning | New capability decomposed into phases and tasks |
| Roadmap creation | Multi-phase delivery strategy with dependencies |
| Project structuring | Organizing a project from scratch |
| Refactoring plan | Incremental structural improvements without behavior change |
| Migration plan | Moving data, services, or frameworks with rollback strategy |
| Integration plan | Connecting external systems safely |
| Architectural initiative | Significant design change with decision records |
| Bug analysis plan | Structured approach to a complex defect |

## Output Structure

The skill generates a `planning/` directory at the root of the project. The structure is proportional to complexity:

```
planning/
├── roadmap.md              ← primary document and index
├── discovery.md            ← initial context and open questions
├── architecture.md         ← when significant decisions are needed
├── risks.md                ← for large or high-risk initiatives
├── rollout.md              ← when production impact requires strategy
├── decisions/
│   └── decision-001-example.md
└── phases/
    ├── phase-01-foundation.md
    ├── phase-02-implementation.md
    └── phase-03-validation.md
```

Small changes may produce only `roadmap.md` and one phase file. The structure must match the actual complexity of the request — not a fixed template.

## Difference Between Planning and Implementation

| Planning (this skill) | Implementation (execution agent) |
|---|---|
| Produces Markdown documents | Produces source code |
| Describes what to build and why | Builds it |
| Defines acceptance criteria | Verifies acceptance criteria |
| Identifies risks | Mitigates risks during coding |
| Declares assumptions | Confirms or refutes assumptions |
| Does not modify source files | Modifies source files |

## How to Update an Existing Roadmap

When `planning/roadmap.md` already exists:

1. Read the existing document first
2. Identify existing phases and their statuses
3. Add new phases without renumbering existing ones unless necessary
4. Update dependency maps and links
5. Register superseded decisions with a `Superseded by` reference
6. Do not delete existing content silently

## How to Use the Templates

Templates are in `templates/`. Use them as starting points for new planning documents:

| Template | Use for |
|---|---|
| `roadmap-template.md` | New `planning/roadmap.md` |
| `phase-template.md` | Each `planning/phases/phase-NN-name.md` |
| `decision-template.md` | Each `planning/decisions/decision-NNN-name.md` |
| `discovery-template.md` | `planning/discovery.md` |

Replace all `{{PLACEHOLDER}}` markers with actual content. Do not leave placeholders in committed planning documents.

## Limits

This skill does not:

- Write, modify, or delete production source code
- Install or remove dependencies
- Execute deployments or CI/CD pipelines
- Mark implementation tasks as completed
- Invent files, commands, or results that have not been observed
- Guarantee that the plan is complete — it declares assumptions and open questions explicitly
