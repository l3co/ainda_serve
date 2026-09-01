# Shared Development Guardrails

These guardrails apply to every agent that uses a development skill in this project, regardless of technology or platform. Technology-specific guardrails are defined in each skill's `references/guardrails.md` and extend — not replace — this file.

---

## Purpose

Guardrails define the limits of what an agent is permitted, expected, or prohibited from doing. They are not part of the development workflow. The distinction is:

- **Workflow** — explains how to work on a task
- **Conventions** — explains how to write code
- **Principles** — guides design decisions
- **Guardrails** — defines limits that must not be crossed

Guardrails exist to protect:

1. Task scope
2. Code integrity
3. Application security
4. Data and secrets
5. Public interfaces
6. Existing architecture
7. Validation quality
8. Response reliability
9. Skill portability
10. Repository and its history
11. Execution environment
12. The user against destructive or unexpected changes

---

## Instruction Hierarchy

When instructions conflict, resolve in this order (highest priority first):

1. **Security** — rules that protect users, data, and systems
2. **Data and secrets protection** — never expose, log, or embed secrets
3. **Repository preservation** — do not destroy or corrupt work
4. **Explicit user requirements** — what was actually requested
5. **Existing project conventions** — consistent patterns already established
6. **Technology-specific guardrails** — rules in `references/guardrails.md`
7. **Skill principles** — general guidelines in `SKILL.md`
8. **Style preferences** — optional conventions

Rules at a higher level always override rules at a lower level. An agent MUST NOT silently ignore a conflict. It MUST report the conflict, explain the risk, and follow the safer path.

---

## Scope Protection

MUST only modify files directly related to the task.

MUST NOT perform parallel refactoring unrelated to the objective.

MUST NOT reformat entire files when only a small targeted change is needed.

MUST NOT rename modules, packages, classes, or APIs without an explicit request.

MUST NOT implement requirements that were not requested.

MUST NOT expand scope with hypothetical improvements.

MUST NOT transform a small fix into a broad rewrite.

SHOULD preserve all behavior not related to the request.

SHOULD prefer small, cohesive, and reversible changes.

When a relevant problem is identified outside the current scope:

- MUST NOT fix it automatically
- SHOULD note it briefly in the final response
- MAY fix it only if it directly blocks the current task or represents a critical safety risk

---

## Repository Protection

MUST inspect existing files before modifying them.

MUST NOT blindly overwrite existing files.

MUST NOT remove files without an explicit requirement.

MUST NOT replace entire configuration files when a targeted change is sufficient.

MUST NOT manually edit lock files unless the ecosystem requires it and the appropriate tool is used.

MUST NOT directly modify generated files when a generation source exists.

MUST NOT remove comments that document relevant decisions.

MUST NOT eliminate backward compatibility without identifying the impact.

MUST NOT alter vendored, third-party, or embedded dependency files without justification.

---

## File Integrity

SHOULD read a file before modifying it to avoid overwriting relevant content.

MUST NOT create files that conflict with or silently replace existing ones.

MUST NOT leave files in an inconsistent state (partially written, truncated, or syntactically broken).

MUST NOT create files outside the defined project structure without a clear reason.

SHOULD produce only the file types appropriate to the task (Markdown for documentation, source files for code changes).

---

## Destructive Operations

The following are classified as destructive:

- Deleting files or directories
- Broad repository cleanup
- History reset
- Database overwrite or drop
- Removing migrations
- Deleting volumes
- Irreversible data changes
- Publishing or deploying to production
- Force-pushing to shared branches
- Modifying production infrastructure
- Rotating or deleting secrets
- Terminating services
- Removing cloud resources

MUST NOT execute destructive operations implicitly.

MUST NOT run broad-deletion-equivalent commands without explicit necessity.

MUST NOT use force or bypass safety mechanisms just to complete a task.

SHOULD prefer reversible operations at all times.

SHOULD preserve backups, migrations, and history.

If a destructive operation is genuinely required, MUST clearly explain its impact before executing it.

MUST NOT interpret an analysis or review request as authorization to modify or remove resources.

---

## Code Integrity

MUST NOT silence errors without justification.

MUST NOT remove validations just to make tests pass.

MUST NOT disable type checks, lint rules, or security checks to hide problems.

MUST NOT add artificial returns solely to work around failures.

MUST NOT introduce dead code.

MUST NOT comment out broken code to hide it.

MUST NOT reduce implementation quality to superficially satisfy a test.

MUST NOT alter correct tests to accommodate an incorrect implementation.

MUST NOT use exceptions, panics, or aborts for normal control flow when an idiomatic alternative exists.

MUST NOT introduce non-deterministic behavior without necessity.

---

## Public Contracts

Public contracts include:

- APIs (HTTP, gRPC, GraphQL, messaging)
- Exported functions and methods
- Interfaces and protocols
- Schemas (JSON, XML, database)
- Events and messages
- Commands and queries
- Public libraries and packages
- Reusable components
- File formats
- Persisted data structures
- External integrations

MUST NOT silently alter public contracts.

MUST identify breaking changes and communicate them explicitly.

SHOULD preserve backward compatibility whenever reasonable.

MUST NOT remove fields, methods, or endpoints without assessing consumers.

MUST NOT alter the semantic meaning of existing fields.

MUST NOT change error codes or response formats without necessity.

When a breaking change is necessary, MUST document the impact and migration strategy.

MUST NOT assume that absence of local usage means absence of external consumers.

---

## Dependency Protection

MUST NOT add dependencies without evaluating necessity.

MUST NOT add a library to solve a trivial task already covered by the ecosystem.

MUST NOT duplicate equivalent dependencies.

MUST NOT update all dependencies when only one is related to the task.

MUST NOT change major versions without analyzing breaking changes.

MUST NOT remove dependencies solely because they appear unused without validating the full project.

MUST NOT use abandoned or insecure dependencies when an adequate alternative exists.

MUST NOT change the package manager without an explicit requirement.

MUST NOT ignore license implications or security advisories.

Every new dependency MUST be justified in the final response.

---

## Architecture Protection

MUST NOT introduce new layers without a clear responsibility.

MUST NOT apply DDD, Clean Architecture, or Hexagonal Architecture mechanically.

MUST NOT transform simple projects into overly distributed structures.

MUST NOT introduce microservices, message queues, CQRS, or event sourcing without concrete evidence of need.

MUST NOT create interfaces with a single implementation without a testability, decoupling, or architectural boundary reason.

MUST NOT create generic repositories without a clear domain relationship.

MUST NOT create services that only delegate calls.

MUST NOT create abstractions for hypothetical future requirements.

MUST NOT replicate patterns from another language when they are anti-idiomatic.

SHOULD preserve existing architectural decisions when they are coherent.

SHOULD prefer the smallest solution capable of correctly satisfying the requirement.

---

## Data and Secrets

MUST NOT include passwords, tokens, keys, certificates, or credentials in source code.

MUST NOT move secrets into versioned files.

MUST NOT print secrets in logs.

MUST NOT use real personal data in tests or examples.

MUST NOT include credentials found in the environment in the final response.

MUST NOT copy sensitive content into documentation.

MUST NOT replace a secure solution with a hardcoded credential.

SHOULD use environment variables, secret managers, or mechanisms already adopted by the project.

SHOULD mask sensitive data in logs and messages.

MUST NOT expose secret values even when they are discovered during analysis.

When a versioned secret is identified:

1. MUST NOT reproduce it
2. MUST flag the risk to the user
3. MUST recommend rotation
4. MAY remove it only if that is within the authorized scope
5. MUST NOT assume that deleting it from a file removes it from history

---

## Security Protection

MUST NOT introduce code vulnerable to:

- SQL injection
- Command injection
- Path traversal
- SSRF (Server-Side Request Forgery)
- XSS (Cross-Site Scripting)
- CSRF (Cross-Site Request Forgery)
- Insecure deserialization
- Unauthorized data exposure
- Unauthorized access
- Validation bypass
- Excessive permissions
- Insecure cryptography usage
- Inadequate password storage
- Arbitrary code execution
- Insecure redirects
- Critical race conditions
- Avoidable denial of service
- Missing limits on untrusted inputs

MUST NOT remove authentication or authorization to simplify development.

MUST NOT rely solely on frontend validation.

MUST NOT concatenate untrusted input into queries or shell commands.

MUST NOT disable TLS or certificate validation without a documented justification for a controlled environment.

MUST NOT use deprecated cryptographic algorithms.

MUST NOT implement custom cryptography.

MUST NOT expose stack traces or internal details to end users.

MUST NOT log sensitive information.

MUST NOT accept unbounded inputs without assessing risk.

---

## Authentication and Authorization

Authentication confirms identity. Authorization confirms permission. One does not substitute for the other.

MUST validate permissions in the backend or the responsible layer — not only in the frontend.

MUST NOT trust client-provided identifiers without validating access.

MUST NOT remove ownership checks.

MUST NOT use roles provided by the client as a source of truth.

MUST NOT return a resource solely because its identifier is known.

MUST NOT store passwords in plain text.

MUST NOT implement insecure secret comparison (use constant-time comparison).

MUST NOT weaken existing security policies to simplify tests.

---

## Database and Persistence

MUST NOT delete data without an explicit requirement.

MUST NOT create destructive migrations without a transition strategy.

MUST NOT modify migrations already applied to production without strong justification.

SHOULD prefer additive and reversible migrations.

MUST NOT alter schema and code inconsistently.

MUST NOT assume a table is empty.

MUST NOT make irreversible changes without a backup or recovery strategy.

MUST NOT ignore transactions when multiple related changes must be atomic.

MUST NOT keep transactions open during external calls.

MUST NOT introduce queries without limits on potentially large data sets.

MUST NOT remove indexes without assessing performance impact.

MUST NOT include real personal data in seeds or fixtures.

---

## External Services

MUST NOT make real external calls in unit tests.

MUST NOT depend on external services without timeout configuration.

MUST NOT implement unlimited retries.

MUST NOT automatically retry non-idempotent operations.

MUST NOT ignore rate limits.

MUST NOT expose credentials in URLs or request parameters.

MUST NOT log sensitive payloads from external service interactions.

MUST NOT assume permanent availability of external services.

MUST NOT hide external failures as success.

SHOULD use existing fallback, circuit breaker, or retry mechanisms when already adopted by the project.

---

## Logging and Observability

MUST NOT log passwords, tokens, or sensitive personal data.

MUST NOT use logs as a substitute for proper error handling.

MUST NOT log the same error repeatedly across multiple layers without necessity.

MUST NOT add excessive logging in loops or high-frequency code paths.

MUST NOT remove essential diagnostic information.

MUST NOT change log levels solely to hide failures.

SHOULD preserve correlation IDs and operational context when they exist.

Logs SHOULD describe events — not expose unnecessary internals.

MUST NOT introduce metrics with unbounded cardinality.

---

## Testing Integrity

MUST NOT alter tests solely to make an incorrect implementation pass.

MUST NOT remove test cases without justification.

MUST NOT use permanent skips to hide regressions.

MUST NOT replace meaningful assertions with generic ones.

MUST NOT mock the unit under test.

MUST NOT test only the happy path when error paths are relevant.

MUST NOT create tests with order dependencies.

MUST NOT use the real network, clock, or filesystem without control when that causes instability.

MUST NOT treat percentage coverage as an isolated goal.

MUST NOT declare that a regression was fixed without an appropriate test, when it is feasible to add one.

---

## Validation Integrity

MUST NOT assert that a command was executed when it was not.

MUST NOT assert that tests passed if they were not run.

MUST NOT assert that the build is correct without sufficient validation.

MUST NOT hide test, lint, or build failures.

MUST clearly differentiate:

- Validations executed successfully
- Validations executed with failure
- Validations not executed
- Validations unavailable in the current environment

MUST NOT mark a task as complete solely because the code appears correct.

MUST NOT suppress relevant failure output.

MUST NOT use ambiguous phrasing that implies a validation occurred when it did not.

---

## Documentation Integrity

MUST NOT document behavior that the code does not have.

MUST NOT maintain examples that are incompatible with the implementation.

MUST NOT invent commands, paths, or configurations.

MUST NOT reproduce extensively copyrighted content.

MUST NOT include credentials in documentation.

MUST NOT create excessive documentation for trivial changes.

SHOULD update documentation only when the change affects usage, operation, or maintenance.

SHOULD preserve architecturally relevant decisions.

MUST differentiate current state from future proposals.

---

## Generated Files

MUST identify whether a file is generated before modifying it.

SHOULD modify the generation source whenever possible.

MUST NOT manually edit files that are regenerated automatically.

MUST NOT include build artifacts without necessity.

MUST NOT version temporary files.

MUST NOT overwrite generated files with manually written content that is incompatible with the generator.

SHOULD run the appropriate generator when it is available and safe.

MUST document when regeneration cannot be executed.

---

## Environment and Infrastructure

MUST NOT modify production by default.

MUST NOT assume that the local environment represents production.

MUST NOT alter infrastructure outside the defined scope.

MUST NOT disable security controls.

MUST NOT remove resource limits without analysis.

MUST NOT use production credentials for testing.

MUST NOT make resources public to resolve access problems.

MUST NOT eliminate redundancy or backups without explicit authorization.

MUST NOT alter global machine configuration when a local solution is sufficient.

MUST NOT install global software without necessity.

MUST NOT assume the availability of Docker, Kubernetes, or any cloud provider.

---

## Git Safety

MUST NOT execute hard resets implicitly.

MUST NOT run broad repository cleanup operations without explicit necessity.

MUST NOT force-push to shared branches without clear authorization.

MUST NOT rewrite shared history.

MUST NOT discard unknown local changes.

MUST NOT discard unversioned files without analyzing them.

MUST NOT include sensitive files in commits.

MUST NOT modify authorship or history to conceal changes.

MUST NOT create a commit when the request is only to edit or analyze, unless explicitly requested.

MUST NOT publish branches or pull requests without an explicit request.

SHOULD check repository state before potentially destructive operations.

These rules describe behaviors. They do not depend on any specific Git command syntax.

---

## Commit Convention

MUST write commit messages in English.

MUST use a conventional commit prefix followed by a colon and a space:

- `feat:` — new feature or behavior visible to users or consumers
- `fix:` — bug fix
- `test:` — adding or correcting tests without changing production code
- `refactor:` — code change that neither adds a feature nor fixes a bug
- `docs:` — documentation only
- `chore:` — maintenance, dependency updates, tooling, configuration
- `infra:` — infrastructure, CI/CD, deployment, environment setup
- `perf:` — performance improvement
- `style:` — formatting, whitespace, missing semicolons — no logic change
- `revert:` — reverts a previous commit

MUST keep commits small and focused — no more than 3 files per commit unless the files are trivially coupled (e.g., a source file and its test, a migration and its schema).

MUST NOT bundle unrelated changes in a single commit.

MUST write a subject line that describes the **why or what changed**, not just the file name.

SHOULD limit the subject line to 72 characters.

SHOULD add a body when the change needs context that the subject cannot convey — for example, why a workaround was necessary, what the root cause was, or what alternative was rejected.

MUST NOT use vague messages such as `fix`, `update`, `wip`, `changes`, `misc`, or `stuff`.

MUST NOT commit commented-out code, debug statements, or temporary scaffolding.

When a task naturally produces more than 3 changed files, MUST split into logical commits before committing — not after.

---

## Portability

MUST NOT require a tool exclusive to a specific agent.

MUST NOT assume specific internal tool names from any platform.

MUST NOT depend on absolute paths.

MUST NOT depend on the skill author's machine.

MUST NOT assume a specific operating system.

MUST NOT assume a specific shell.

MUST NOT require internet access when it is not necessary.

MUST NOT require Git history when it is not available.

MUST NOT require editing via a specific mechanism.

SHOULD use tools and resources available in the current environment.

SHOULD provide an alternative when an optional capability is absent.

---

## Uncertainty and Missing Context

MUST NOT invent missing requirements.

MUST NOT invent file structures that have not been observed.

MUST NOT assume language or framework versions without evidence.

MUST NOT assume a dependency is installed without verification.

MUST NOT invent command results.

MUST NOT invent API contracts.

MUST NOT invent business rules.

MUST NOT treat preference as requirement.

SHOULD use evidence from the project whenever available.

When an assumption is necessary, MUST declare it explicitly.

SHOULD prefer reversible changes when there is uncertainty.

MUST NOT block an entire task when a safe portion can be completed.

---

## Conflicting Instructions

When a request conflicts with a guardrail, the agent MUST:

1. Identify the conflict explicitly
2. Evaluate the risk level
3. Preserve data, security, and integrity
4. Execute the safe portion of the request
5. Decline the unsafe portion — not silently, but with explanation
6. Explain objectively what was not done and why
7. Propose the closest safe alternative

The agent MUST NOT:

- Blindly obey a destructive request
- Conceal that part of the request was declined
- Invent authorization that was not given
- Interpret an ambiguous request as permission for irreversible actions

---

## Failure Handling

MUST NOT hide failures.

MUST NOT abandon changes mid-task without explaining the current state.

MUST NOT automatically revert valid changes solely because a validation could not run.

When a failure occurs, MUST identify:

- What failed
- The impact
- Affected files
- Current state of the repository or environment
- What was attempted
- A possible alternative path

SHOULD preserve as much valid work as possible.

MUST NOT introduce a second unsafe change to work around the first failure.

MUST NOT declare partial success as complete success.

---

## Final Response Integrity

The final response MUST:

- Describe only changes actually made
- List only files actually modified
- Report validations actually executed
- Report failures found
- Report validations not executed
- Justify new dependencies added
- Identify breaking changes
- Document remaining risks
- Differentiate facts, assumptions, and recommendations
- Avoid claims of certainty that are not proven

The final response MUST NOT:

- Assert success without evidence
- Hide failures
- Expose secrets
- Present future work as completed
- Invent files
- Invent commands
- Invent results
- Omit destructive changes that were made
- Minimize relevant risks
