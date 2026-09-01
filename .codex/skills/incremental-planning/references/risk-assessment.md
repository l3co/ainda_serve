# Risk Assessment

Risk assessment in incremental planning is not about predicting the future — it is about structuring uncertainty so it can be addressed deliberately rather than discovered accidentally.

---

## Risk Identification

Identify risks by examining:

- Areas where assumptions are uncertain
- External dependencies outside the team's control
- Irreversible or hard-to-reverse changes
- Parts of the system with limited test coverage
- Integrations with poorly documented behavior
- Migrations that affect existing data
- Changes to public contracts with unknown consumers
- Performance-sensitive paths that have not been profiled
- Security-sensitive operations
- Phases that depend on decisions not yet taken

Do not invent risks for completeness. Document only risks with a plausible path to materialization.

---

## Risk Classification

### Categories

| Category | Description |
|---|---|
| `architecture` | Design decisions that may not fit the actual requirements |
| `implementation` | Technical complexity or unfamiliar patterns |
| `security` | Vulnerabilities, exposure of sensitive data, broken auth |
| `data` | Data loss, corruption, or inconsistency during migration or change |
| `integration` | External service instability, API changes, contract drift |
| `performance` | Latency, throughput, or resource usage under load |
| `operations` | Deployment complexity, monitoring gaps, runbook absence |
| `schedule` | Scope growth, external blockers, dependency delays |
| `dependency` | Library removal, breaking changes, license problems |
| `knowledge` | Key person dependency, unfamiliar technology, insufficient documentation |
| `migration` | Irreversible changes to data, schema, or infrastructure |
| `compatibility` | Breaking changes for existing consumers or clients |

### Likelihood

| Value | Meaning |
|---|---|
| `Low` | Unlikely under normal conditions |
| `Medium` | Plausible; has happened in similar situations |
| `High` | Likely; known preconditions exist |
| `Critical` | Almost certain unless explicitly mitigated |

### Impact

| Value | Meaning |
|---|---|
| `Low` | Minor inconvenience; easy recovery |
| `Medium` | Noticeable disruption; moderate recovery effort |
| `High` | Significant failure; difficult recovery; users affected |
| `Critical` | Data loss, security breach, or service outage |

### Detectability

| Value | Meaning |
|---|---|
| `High` | Problem is immediately visible when it occurs |
| `Medium` | Problem may go unnoticed for minutes or hours |
| `Low` | Problem may go unnoticed for days or longer |

---

## Risk Table Format

```markdown
| Risk | Category | Likelihood | Impact | Detectability | Mitigation |
|---|---|---|---|---|---|
| External payment API may not support idempotency keys | Integration | Medium | High | Medium | Use sandbox environment in Phase 01 to verify behavior before Phase 03 |
| Schema migration may fail on large tables | Migration | Medium | Critical | High | Run migration on a staging clone first; prepare rollback SQL |
| Removal of legacy endpoint breaks unknown consumers | Compatibility | High | High | Low | Keep old endpoint for 30 days; monitor traffic before removal |
```

Do not assign percentages. Use the qualitative scales above.

---

## Risk Response Strategies

For each identified risk, choose a response strategy:

| Strategy | Description |
|---|---|
| **Avoid** | Redesign the approach to eliminate the risk |
| **Mitigate** | Reduce likelihood or impact through proactive action |
| **Accept** | Acknowledge the risk and proceed; document the decision |
| **Transfer** | Use a contract, insurance, or third-party service to handle the risk |
| **Defer** | Postpone the risky activity until more information is available |
| **Monitor** | Track indicators that would signal the risk materializing |

For High and Critical risks, always document the mitigation or the acceptance rationale. Acceptance without rationale is not a decision — it is an oversight.

---

## Mitigation Strategies by Category

### Architecture Risks

- Validate the proposed design with a minimal prototype before full implementation
- Review against existing conventions in the project
- Document trade-offs and the rejected alternatives

### Implementation Risks

- Identify the most uncertain piece and spike it first
- Document invariants and edge cases in the task
- Add review checkpoints before continuing to dependent phases

### Security Risks

- Perform a threat model before the security-sensitive phase
- Reference the project's security checklist
- Include security validation in acceptance criteria, not only in tests

### Data Risks

- Run the migration on a copy of production data before executing
- Test rollback from the migrated state
- Include data integrity assertions as part of the validation
- Identify which data changes are irreversible before starting

### Integration Risks

- Use the external service's sandbox environment early
- Implement timeout, retry, and circuit breaker before going live
- Write contract tests to detect API changes
- Prepare fallback behavior for when the external service is unavailable

### Performance Risks

- Profile before optimizing — establish a baseline
- Test under realistic load before declaring the phase complete
- Identify which queries, calls, or computations are on the critical path

### Operations Risks

- Write the runbook before the deployment, not after
- Define monitoring thresholds and alert conditions
- Define rollback criteria and procedures

### Migration Risks

- Always prepare a rollback script before running a migration
- Run migrations on a non-production environment first
- Add a stabilization period before marking the migration complete
- Identify which migration steps are irreversible

### Compatibility Risks

- Monitor traffic to endpoints before removing them
- Use a versioning strategy when changing public contracts
- Communicate breaking changes to known consumers before executing

---

## Rollback and Recovery Planning

For every phase classified as High or Critical risk, document:

```markdown
## Rollback or recovery

**Detection:** What signal indicates that this phase has caused a problem?
- Example: Error rate above baseline for 10 minutes in the affected endpoint.

**Stop condition:** When do we halt?
- Example: At the first alert indicating degraded availability.

**Recovery procedure:**
1. Revert the deployment or disable the feature flag.
2. Run the rollback migration script: `planning/scripts/rollback-phase-03.sql` (Proposed path).
3. Verify that the previous behavior is restored.
4. Document the incident.

**Irreversible actions in this phase:**
- None — migration uses additive columns only in this phase.

**Data at risk:**
- None — this phase does not delete or transform existing data.
```

---

## Risk Summary in Roadmap

The roadmap's risk summary section should:

- List the top 3–5 risks by combined Likelihood + Impact
- Note which phase each risk belongs to
- Reference the mitigation strategy
- Flag which risks require a decision before the affected phase can begin

Do not reproduce the full risk table in the roadmap. Reference the detailed risk document when one exists.

---

## Residual Risk

After mitigation, document the residual risk — what remains even after the mitigation is applied. This is the risk the team accepts.

When residual risk is High or Critical, the acceptance must be explicit and recorded in the relevant decision document.
