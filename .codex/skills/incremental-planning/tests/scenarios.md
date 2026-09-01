# Incremental Planning — Test Scenarios

These scenarios validate whether an agent correctly applies the `incremental-planning` skill. Each scenario describes a realistic context and request.

---

## Scoring Rubric

| Score | Meaning |
|---|---|
| **3 — Pass** | All expected behaviors exhibited; all approval criteria met |
| **2 — Partial** | Most expected behaviors; one or two criteria missed |
| **1 — Marginal** | Core intent partial; a prohibited behavior observed |
| **0 — Fail** | Expected behavior absent or skill refused without justification |

---

## Scenario 01 — Small Feature

**Context:** A Go web service with existing tests and a `CLAUDE.md` referencing the go-development skill.

**Request:** "Plan the addition of an endpoint that returns the current server version."

**Expected skill behavior:**
- Produces `planning/roadmap.md` and one phase file
- Does not create discovery, architecture, or multiple ADRs
- Phase has one or two tasks maximum
- Tasks reference existing files with `Existing file` label
- Does not implement the endpoint

**Expected files:**
```
planning/
├── roadmap.md
└── phases/
    └── phase-01-version-endpoint.md
```

**Required assumptions:** None significant; version source may need clarification.

**Prohibited behavior:**
- Creating unnecessary phases or ADRs
- Implementing the endpoint
- Generating an architecture document for a trivial change

**Approval criteria:**
- Structure matches the small-change template
- No code written
- Tasks are specific and individually verifiable

---

## Scenario 02 — Medium Feature

**Context:** An Elixir Phoenix project with Ecto and existing authentication.

**Request:** "Plan the implementation of a product search endpoint with category, price range, and stock availability filters."

**Expected skill behavior:**
- Produces roadmap, discovery (if questions exist), and 2–4 phase files
- Phase 01 defines the API contract before any implementation
- Identifies at least one decision (full-text vs. SQL filtering)
- Notes pagination as out of scope or a deferred decision
- Does not implement the endpoint

**Expected files:**
```
planning/
├── roadmap.md
├── discovery.md
└── phases/
    ├── phase-01-api-contract.md
    ├── phase-02-query-implementation.md
    └── phase-03-validation.md
```

**Required assumptions:** Pagination behavior (in or out of scope for v1).

**Prohibited behavior:**
- Implementing the query
- Skipping the API contract phase
- Declaring decisions as Accepted without user input

**Approval criteria:**
- Contract precedes implementation
- Decision documented as Proposed
- Each phase has acceptance criteria
- All relative links are valid

---

## Scenario 03 — Project from Scratch

**Context:** No existing codebase. User wants to start a new order management service.

**Request:** "Plan the structure of a new order management service in Go."

**Expected skill behavior:**
- Creates `planning/discovery.md` before the roadmap (insufficient context)
- Identifies open questions about tech stack, deployment, and integrations
- Proposes a minimal initial structure
- Does not generate five ADRs and ten phases for a new service with no requirements

**Expected files:**
```
planning/
├── discovery.md
└── roadmap.md     ← after enough context to proceed
```

**Required assumptions:** Language confirmed (Go); framework, database, and deployment target unknown.

**Prohibited behavior:**
- Generating a full multi-phase roadmap without first capturing open questions
- Inventing a project structure that has not been confirmed

**Approval criteria:**
- Discovery document created first
- Open questions explicitly listed
- Assumptions declared
- Plan proportional to available information

---

## Scenario 04 — Legacy Project

**Context:** A Java monolith with no tests and no documentation. The codebase is 5 years old.

**Request:** "Plan how to add a new payment method (bank transfer) to the existing checkout flow."

**Expected skill behavior:**
- Inspects the existing project structure before planning
- Identifies the absence of tests as a risk
- Proposes characterization tests before modifying existing behavior
- Does not import DDD or Clean Architecture unless already present in the project

**Expected files:**
```
planning/
├── roadmap.md
├── discovery.md
└── phases/
    ├── phase-01-characterization-tests.md
    ├── phase-02-bank-transfer-core.md
    └── phase-03-checkout-integration.md
```

**Required assumptions:** Existing checkout flow is not unit-tested; characterization tests needed as safety net.

**Prohibited behavior:**
- Adding new behavior before characterizing existing behavior
- Assuming the project structure without reading it

**Approval criteria:**
- Test safety net is Phase 01
- Legacy code risks documented
- No architecture imported from outside

---

## Scenario 05 — Refactoring

**Context:** A Python service with a `UserService` class handling authentication, profile update, and email notification in one method.

**Request:** "Plan a refactoring to separate the concerns in `UserService.update_profile`."

**Expected skill behavior:**
- Starts with a characterization test phase
- Extracts one concern per phase (not all at once)
- Marks each phase as behavior-preserving
- Does not change API or behavior — only structure
- Does not implement the refactoring

**Expected files:**
```
planning/
├── roadmap.md
└── phases/
    ├── phase-01-characterization-tests.md
    ├── phase-02-extract-email-notification.md
    └── phase-03-extract-authentication-check.md
```

**Prohibited behavior:**
- Merging all extractions into one phase
- Changing behavior during refactoring
- Missing the test safety net

**Approval criteria:**
- Each phase preserves all existing tests
- Behavior unchanged throughout
- Each extraction is independently verifiable

---

## Scenario 06 — Complex Bug

**Context:** An Elixir service. A race condition causes duplicate orders under concurrent requests.

**Request:** "Plan how to investigate and fix the duplicate order race condition."

**Expected skill behavior:**
- Phase 01 is investigation: reproduce and characterize the race condition
- Phase 02 is fix: implement the concurrency control
- Phase 03 is validation: verify under concurrent load
- Notes that Phase 02 depends on findings from Phase 01
- Does not declare a fix without knowing the root cause

**Required assumptions:** Root cause unknown; investigation is the first deliverable.

**Prohibited behavior:**
- Proposing a fix before investigation
- Declaring the race condition resolved in the planning document

**Approval criteria:**
- Investigation is an explicit deliverable
- Phase 02 is marked as depending on Phase 01 findings
- Acceptance criteria include concurrent request testing

---

## Scenario 07 — Database Migration

**Context:** A PostgreSQL-backed service. The `users.name` column must be split into `first_name` and `last_name`.

**Request:** "Plan the migration of the `name` column to `first_name` and `last_name`."

**Expected skill behavior:**
- Uses an additive migration strategy (add first, backfill, switch reads, remove)
- Phase for column removal is marked as irreversible
- Includes a rollback procedure for each phase
- Includes data integrity validation
- Does not execute the migration

**Expected files:**
```
planning/
├── roadmap.md
├── decisions/
│   └── decision-001-migration-strategy.md
└── phases/
    ├── phase-01-additive-schema.md
    ├── phase-02-dual-write.md
    ├── phase-03-backfill.md
    ├── phase-04-read-migration.md
    └── phase-05-column-removal.md
```

**Prohibited behavior:**
- Single destructive migration in one step
- No rollback strategy
- Missing data integrity validation

**Approval criteria:**
- Column removal phase explicitly marked irreversible
- Rollback procedure present per phase
- Migration tested on non-production environment before proceeding

---

## Scenario 08 — Public API Change

**Context:** A REST API with external consumers. A field must be renamed.

**Request:** "Plan the renaming of the `user_name` field to `fullName` in the user response."

**Expected skill behavior:**
- Flags this as a breaking change
- Proposes a transition period with both fields present simultaneously
- Includes consumer communication in the plan
- Documents the deprecation and removal timeline

**Prohibited behavior:**
- Silently renaming the field in one step
- Assuming no external consumers exist

**Approval criteria:**
- Breaking change explicitly flagged
- Transition strategy documented
- Consumer impact assessed

---

## Scenario 09 — External Integration

**Context:** A React + Node.js application. A third-party SMS provider must be integrated for 2FA.

**Request:** "Plan the integration with the Twilio SMS API for two-factor authentication."

**Expected skill behavior:**
- Phase 01 defines the SMS sender interface with a fake implementation
- Phase 02 implements 2FA logic against the fake
- Phase 03 replaces the fake with the real Twilio client
- Notes that Phase 03 requires sandbox credentials as an external dependency
- Does not hardcode credentials or API keys in the plan

**Prohibited behavior:**
- Including API keys or secrets in planning documents
- Skipping the fake implementation phase
- Implementing the integration directly

**Approval criteria:**
- Interface defined before real implementation
- Sandbox credentials identified as an external dependency
- No secrets in planning documents

---

## Scenario 10 — Multi-Team Initiative

**Context:** A platform initiative involving three teams: backend, frontend, and mobile.

**Request:** "Plan the rollout of a new authentication flow across all three teams."

**Expected skill behavior:**
- Identifies cross-team dependencies explicitly
- Plans a phased rollout with team-specific phases
- Identifies the API contract as a hard dependency for all downstream teams
- Marks phases that require coordination across teams
- Does not assume a single team can execute all phases

**Prohibited behavior:**
- Treating the initiative as a single-team effort
- Missing cross-team dependency documentation

**Approval criteria:**
- Each team's work has its own phase or sub-tasks
- API contract is Phase 01 for all dependent teams
- Cross-team dependencies explicitly classified

---

## Scenario 11 — Vague Request

**Context:** No existing project context provided.

**Request:** "Plan the implementation of a notification system."

**Expected skill behavior:**
- Creates `planning/discovery.md` before the roadmap
- Lists all open questions (notification types, channels, sync or async, etc.)
- Declares explicit assumptions to allow partial planning
- Does not invent an architecture without evidence of requirements

**Prohibited behavior:**
- Creating a complete multi-phase roadmap without capturing open questions first
- Inventing a Kafka-based event-driven pipeline without evidence it is needed

**Approval criteria:**
- Discovery document created
- Open questions explicitly listed
- Assumptions declared and tagged with impact
- Plan proportional to what is known

---

## Scenario 12 — Contradictory Requirements

**Context:** User provides two conflicting requirements in the same request.

**Request:** "Plan the new checkout flow. It must support guest checkout and require login for order history."

**Expected skill behavior:**
- Identifies the apparent contradiction explicitly
- Documents both requirements
- Proposes how they can coexist (guest checkout proceeds; order history requires login)
- Does not silently pick one and ignore the other

**Prohibited behavior:**
- Ignoring one requirement
- Silently resolving the conflict without surfacing it

**Approval criteria:**
- Conflict documented in discovery or roadmap
- Resolution proposed with rationale
- User asked to confirm if the interpretation is correct

---

## Scenario 13 — No Tests in Project

**Context:** A Node.js project with no test framework configured.

**Request:** "Plan the implementation of a coupon discount feature."

**Expected skill behavior:**
- Identifies the absence of tests as a risk
- Recommends a phase to establish a minimal test foundation before or alongside feature work
- Does not mandate a complete test infrastructure as a prerequisite
- Notes the risk explicitly in the roadmap

**Prohibited behavior:**
- Ignoring the absence of tests
- Blocking all feature work until a complete test suite exists

**Approval criteria:**
- Test absence documented as risk
- Mitigation proposed
- Feature phases include validation even without a formal test framework

---

## Scenario 14 — No Documentation

**Context:** A service with no README, no ADRs, and no inline documentation.

**Request:** "Plan the addition of an admin reporting dashboard."

**Expected skill behavior:**
- Inspects the directory structure to understand existing patterns
- Notes the documentation gap as a risk (knowledge dependency)
- Does not invent a project structure that was not observed
- May suggest adding a README as a task but does not make it a blocking prerequisite

**Prohibited behavior:**
- Inventing an architecture not observed in the project
- Blocking the feature plan on documentation that does not exist

**Approval criteria:**
- Documentation gap noted as risk
- Plan based only on observed project structure
- File labels (`Existing file`, `New file`) used accurately

---

## Scenario 15 — Existing Roadmap

**Context:** `planning/roadmap.md` already exists with three phases, one of which is In Progress.

**Request:** "Add a new phase for observability to the existing roadmap."

**Expected skill behavior:**
- Reads the existing roadmap before making changes
- Continues the existing phase numbering
- Adds Phase 04 without renumbering existing phases
- Updates the phase table and navigation links
- Does not overwrite existing content

**Prohibited behavior:**
- Overwriting the existing roadmap silently
- Renumbering phases without justification
- Changing the status of existing phases

**Approval criteria:**
- Existing phases preserved
- New phase added with correct numbering
- Navigation links updated
- No existing content removed

---

## Scenario 16 — Single-Phase Task

**Context:** A well-understood Python service with good test coverage.

**Request:** "Plan the addition of a rate limit header to all API responses."

**Expected skill behavior:**
- Produces `planning/roadmap.md` and one phase file with 2–3 tasks
- Does not split into multiple phases
- Does not create a discovery document or ADRs
- Tasks reference exact files if inspectable

**Expected files:**
```
planning/
├── roadmap.md
└── phases/
    └── phase-01-rate-limit-header.md
```

**Prohibited behavior:**
- Generating unnecessary phases
- Creating architecture or risk documents for a trivial change

**Approval criteria:**
- Structure matches small-change template
- One phase is sufficient and appropriate

---

## Scenario 17 — Over-Architectural Request

**Context:** A simple CRUD service.

**Request:** "Plan the addition of a soft-delete feature using CQRS and event sourcing."

**Expected skill behavior:**
- Questions whether CQRS and event sourcing are necessary for the actual requirement
- Proposes the simplest approach first (`deleted_at` column with a filter)
- Documents what CQRS/ES would add and at what cost
- Does not plan the complex architecture without explicit user confirmation

**Prohibited behavior:**
- Blindly planning CQRS and event sourcing for a soft-delete
- Not surfacing the simpler alternative

**Approval criteria:**
- Simple alternative documented and proposed first
- Complex approach shown as an option with trade-offs
- User asked to confirm which direction to pursue

---

## Scenario 18 — Gradual Rollout Required

**Context:** A high-traffic e-commerce API. An endpoint response format is changing.

**Request:** "Plan the change to the product search response format."

**Expected skill behavior:**
- Identifies this as a public contract change
- Plans a versioned or flag-based transition
- Includes a stabilization period before removing the old format
- Documents consumer impact and rollback criteria

**Prohibited behavior:**
- Replacing the format in a single deployment
- Ignoring external consumers

**Approval criteria:**
- Transition strategy documented
- Old format preserved during transition
- Rollout criteria and rollback procedure present

---

## Scenario 19 — Risk of Data Loss

**Context:** A service with 5 years of production data in PostgreSQL.

**Request:** "Plan the cleanup of orphaned records in the `order_items` table."

**Expected skill behavior:**
- Classifies data deletion as irreversible and high-impact
- Requires a validation query to identify orphaned records before deletion
- Requires a backup or soft-delete approach before hard deletion
- Does not execute any deletion

**Prohibited behavior:**
- Generating a task that deletes data without prior validation
- Treating data deletion as a low-risk change

**Approval criteria:**
- Irreversibility explicitly flagged
- Validation query described before deletion
- Backup or recovery strategy required
- Hard deletion in a separate, later phase

---

## Scenario 20 — Planning and Implementation Requested Together

**Context:** User requests both a plan and the implementation in the same message.

**Request:** "Plan and implement the password strength validation for user registration."

**Expected skill behavior:**
- Produces the plan first
- Clearly states that implementation is a separate next step
- Does not mix planning documents with implementation code

**Prohibited behavior:**
- Implementing the feature while producing the plan
- Omitting the plan and going directly to implementation

**Approval criteria:**
- Plan delivered first
- Implementation explicitly separated
- Final response states "Implementation has not started"

---

## Scenario 21 — Files Cited That Do Not Exist

**Context:** User references a file in the request that does not exist in the project.

**Request:** "Plan the refactoring of `src/services/payment_processor.ex` to extract the retry logic."

**Expected skill behavior:**
- Attempts to confirm the file exists by inspecting the project
- If not found, marks the file as `Proposed path` in the plan
- Does not generate detailed task steps for a file whose existence is uncertain
- Surfaces the uncertainty to the user

**Prohibited behavior:**
- Treating an unconfirmed file path as `Existing file`
- Generating detailed steps for a file that may not exist

**Approval criteria:**
- File classified correctly based on observation
- Uncertainty surfaced to the user
- Plan proceeds safely with appropriate caveats

---

## Scenario 22 — Unknown Validation Commands

**Context:** An unfamiliar project with no README and no documented test runner.

**Request:** "Plan the implementation of input sanitization for the search endpoint."

**Expected skill behavior:**
- Inspects the project for available test commands, scripts, and CI configuration
- Documents what test approach was found, or notes that the test command is unknown
- Uses "Use the test command configured by the project" in validation steps
- Does not invent test commands

**Prohibited behavior:**
- Inventing commands like `npm test` or `pytest` without observing them in the project
- Declaring validations that cannot be executed

**Approval criteria:**
- Validation instructions based on observed project commands
- Unknown commands acknowledged with "configured by the project" phrasing
- No invented commands

---

## Scenario 23 — Parallel Phases Possible

**Context:** A project where backend API and frontend components are independently developed.

**Request:** "Plan the implementation of a product detail page with an API endpoint and a React component."

**Expected skill behavior:**
- Phase 01 defines the API contract (required by both)
- Phase 02 (backend) and Phase 03 (frontend) identified as parallelizable after Phase 01
- Notes that parallel phases must not share files or depend on unresolved decisions

**Prohibited behavior:**
- Sequencing all phases when parallelism is safe
- Proposing parallelism without verifying that phases do not share files

**Approval criteria:**
- Contract phase is sequential and required by both downstream phases
- Parallel work identified and documented in the roadmap
- Shared file conflicts checked

---

## Scenario 24 — External Dependency Blocked

**Context:** A payment integration plan where the payment provider has not yet granted sandbox access.

**Request:** "Plan the integration with the payment gateway."

**Expected skill behavior:**
- Plans all phases that do not require the external credential (interface, fake, core logic)
- Marks the real integration phase as `Blocked` or `Proposed` pending sandbox access
- Documents the external dependency explicitly
- Does not block all planning on the missing credential

**Prohibited behavior:**
- Blocking all planning until credentials are available
- Proceeding with the real integration phase as if credentials were available

**Approval criteria:**
- Independent phases planned despite the blocked dependency
- Blocked phase correctly marked with the dependency documented
- Unblocking condition stated clearly

---

## Scenario 25 — Unconfirmed Architectural Decision

**Context:** A plan that requires choosing between SQL and a document database, but no decision has been made.

**Request:** "Plan the implementation of the product catalog module."

**Expected skill behavior:**
- Creates a decision document for the storage choice with status `Proposed`
- Does not mark the decision as `Accepted`
- Plans foundation phases independent of the storage decision
- Marks phases that depend on the storage decision as `Proposed` until resolved

**Prohibited behavior:**
- Assuming the storage technology without user confirmation
- Marking the decision as Accepted without user input
- Blocking all phases on an undecided question when some work can proceed

**Approval criteria:**
- Decision document created with status `Proposed`
- Independent phases proceed as `Planned`
- Dependent phases marked as `Proposed` with a clear unblocking condition
- User explicitly informed of the pending decision
