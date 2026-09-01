---
name: ruby-development
description: Guides agents in developing, reviewing, refactoring, and evolving Ruby and Rails projects with idiomatic style, small single-responsibility objects, and the design philosophy of 99 Bottles of OOP (Sandi Metz, Katrina Owen). Activate for any task involving a Ruby codebase — plain Ruby, Rails models/controllers/jobs, Hotwire (Turbo/Stimulus) views, RSpec/Minitest tests, or architectural decisions.
---

# Objective

Guide agents to produce correct, idiomatic, maintainable Ruby code — plain
Ruby or Rails — that favors small, single-responsibility objects over
premature abstraction, earns polymorphism through duck typing rather than
type checks, and applies the simplest design that solves the real problem
in front of it right now.

# Fundamental Principles

These are *99 Bottles of OOP*'s values, applied directly to how code gets
written, not just discussed:

- **Shameless green first** — get a passing, honest implementation before
  refactoring it. A concrete, slightly repetitive solution that works is a
  better starting point than a clever abstraction for a case that doesn't
  exist yet.
- **Concrete before abstract** — write the object for the case you have.
  Generalize only once a second, real case shows the actual shape of the
  variation — never predict it in advance.
- **Flocking rules over intuition** — when two pieces of code look similar,
  converge them by making the differences explicit one small step at a
  time (parameterize, extract, rename), not by guessing the "right"
  abstraction and rewriting both at once.
- **Duck typing over type checks** — never branch on `is_a?`/`case obj
  when SomeClass`. If behavior varies by kind, the object itself answers a
  question (`flashcard.concept?`) or implements the message the caller
  needs — the caller never inspects what it's talking to.
- **Small objects, one reason to change** — a class with several unrelated
  attributes that are null together in different combinations (e.g., one
  table doing "identity" and "meeting logistics" at once) is a signal to
  split, not a normal shape to accept.
- **TRUE code** — every abstraction should be **T**ransparent (the
  consequence of a change is obvious), **R**easonable (cost of change is
  proportional to its benefit), **U**sable (works in new contexts without
  modification), **E**xemplary (encourages more of the same quality in
  code that extends it). If an abstraction fails this test, prefer the
  duplicated concrete code over it.
- **The Rule of Three** — tolerate duplication twice; extract an
  abstraction on the third occurrence, when the actual pattern is finally
  visible.
- **Composition over inheritance** by default; reach for inheritance only
  when the relationship is genuinely "is-a" and the subclass never needs
  to override behavior the superclass depends on internally.

# When to Activate

- Writing or modifying `.rb` files: plain Ruby classes/modules, Rails
  models, controllers, jobs, mailers, serializers, Rake tasks
- Writing or reviewing RSpec or Minitest tests
- Working on Rails views using Hotwire (Turbo Drive/Frames/Streams,
  Stimulus controllers) or ERB/Haml/Slim templates
- Designing ActiveRecord models, associations, migrations, or query
  objects
- Reviewing Ruby code for object-design problems: God objects, primitive
  obsession, feature envy, `case`/`is_a?` branching that should be
  polymorphism, service-object junk drawers
- Refactoring Ruby or Rails code for clarity, testability, or idiomatic
  correctness
- Evaluating or proposing architecture for a Ruby/Rails project
- Working with background jobs (Solid Queue, Sidekiq, GoodJob) or caching

# When Not to Use

- The project is in a different language, even one that runs on Ruby
  tooling incidentally (e.g., a Dockerfile in a Ruby repo with no Ruby
  changes)
- The task is purely infrastructure/CI/CD/Docker/deployment configuration
  with no Ruby code changes
- Pure front-end work in a Rails app that uses a separate JS framework
  instead of Hotwire (e.g., a Rails API backing a standalone React app) —
  the Ruby side still applies this skill, the JS side does not

# Behavior Limits

- Do not introduce a service-object layer (`app/services/*Service`) for
  logic that belongs on the model that owns the state. Behavior lives with
  the data it changes; a plain Ruby object outside `ActiveRecord::Base` is
  for behavior that doesn't belong to any single record — and it gets a
  name describing what it does, not a generic `Service` suffix.
- Do not add a state-machine gem (AASM or similar) for a handful of states
  with simple guard-clause transitions. Enum + instance methods that raise
  on an illegal transition is the correct default; escalate only when
  branching genuinely outgrows hand-written guards.
- Do not add Devise, Pundit, CanCanCan, or another heavyweight Rails gem
  before the project's own scaffold (`has_secure_password`, a
  `before_action` ownership check) has actually proven insufficient.
- Do not create a module/namespace for a single class. Namespace only when
  several genuinely coupled classes justify it.
- Do not branch on an object's class or a redundant `type` string field
  when the enum/attribute itself can answer the question via a predicate
  method.
- Do not invent gem names, Rails generator output, or configuration keys —
  verify against the project's `Gemfile`/`Gemfile.lock` and installed
  Rails version.

# Execution Process

1. Read the full request before taking any action.
2. Inspect the project structure: `Gemfile`, `Gemfile.lock`, Rails version
   (`bin/rails -v` or `Gemfile.lock`), directory layout under `app/`.
3. Identify the Ruby and Rails (if applicable) versions in use.
4. Locate configuration: `.rubocop.yml`, `config/application.rb`,
   `config/database.yml`, CI workflow files.
5. Identify existing conventions: naming, module/namespace structure,
   service-object usage (or deliberate absence of it), test framework and
   style already established.
6. Find similar existing implementations (a comparable model, a comparable
   controller action) to align with established patterns before
   introducing a new one.
7. Separate explicit requirements from assumptions.
8. Identify risks, ambiguities, and missing information.
9. Choose the simplest correct design — shameless green over the abstract
   version, unless a third concrete case already justifies the
   abstraction (Rule of Three).
10. Formulate a small, verifiable implementation plan.
11. Implement changes with focus and cohesion; keep each class to one
    reason to change.
12. Add or update tests (RSpec or Minitest, matching the project) covering
    the new behavior, its error paths, and any state transition.
13. Run `bundle exec rubocop` (or the project's configured linter/formatter).
14. Run the project's test suite for the affected area.
15. Review for security issues (see `references/security.md`), N+1 queries,
    and edge cases.
16. Review the final diff for unintended changes.
17. Present results using the standard response format.

# Mandatory Rules

- All identifiers (classes, modules, methods, variables) must be in
  English.
- Test descriptions (`describe`/`it`/`context` or `test` names) must be in
  English.
- Never rescue `StandardError` (or, worse, `Exception`) without a
  documented reason and a narrower rescue where one is possible.
- Never swallow an exception silently — log, re-raise, or handle it
  meaningfully.
- Do not use class variables (`@@foo`) — they leak state across
  subclasses and instances in ways that surprise readers; use class-level
  instance variables or a constant instead.
- Do not monkey-patch a class you do not own (Ruby core classes, gem
  classes) without an explicit, documented reason — prefer a wrapper or
  refinement.
- Do not use `method_missing` when a normal method, `Data.define`, or
  `Struct` would do — reserve it for genuine dynamic-dispatch needs (DSLs,
  proxies).
- In Rails: never build a raw SQL string by interpolating untrusted input
  — use parameterized `where`, `sanitize_sql_array`, or the query
  interface.
- In Rails: never disable CSRF protection, mass-assignment protection
  (strong parameters), or authentication to make a controller easier to
  test — fix the test setup instead.
- Do not add a class solely to group unrelated methods under a namespace
  — that's what a module of module functions is for, not a class.
- Do not expose `attr_accessor` for internal state that callers should
  never set directly — prefer read-only accessors and explicit methods
  for mutation, so the class controls its own invariants.

# Architecture and Organization

See [references/architecture.md](references/architecture.md) for detailed
guidance, including Rails app layout, where behavior belongs (models vs.
plain Ruby objects vs. jobs), and the "collect and dispatch" domain-event
pattern for decoupling side effects from state changes.

# Language and Framework Conventions

See [references/conventions.md](references/conventions.md) for Ruby
naming/style conventions and Rails-specific conventions (ActiveRecord,
controllers, Hotwire).

# Testing Strategy

See [references/testing.md](references/testing.md) for the complete
testing approach — RSpec-first with Minitest noted as an equally valid
substitution, FactoryBot, system specs for Hotwire flows, and how to unit
test plain Ruby domain objects without touching ActiveRecord.

# Mandatory Validations

Before declaring a task complete, confirm:

- [ ] `ruby -c` (or the project's build/boot check) succeeds for changed
      files
- [ ] The project's test suite passes for all affected files
- [ ] `bundle exec rubocop` reports no new offenses (or offenses were
      fixed)
- [ ] No class variables (`@@foo`) introduced
- [ ] No bare `rescue StandardError`/`rescue Exception` introduced without
      justification
- [ ] No raw SQL string interpolation introduced
- [ ] No hardcoded secrets or credentials
- [ ] No new `case obj when SomeClass` / `is_a?` branching where a
      polymorphic method would do

If any validation cannot be executed, declare it explicitly under "Risks
and limitations."

# Completion Criteria

A task is complete when:

1. The requested behavior is correctly implemented and verified.
2. Existing tests continue to pass.
3. New tests cover the new or changed behavior, including error paths and
   state transitions.
4. Code follows Ruby/Rails idioms and this project's existing conventions.
5. No class introduced or modified has more than one reason to change; no
   abstraction was added without a second concrete case justifying it.
6. The diff is minimal and focused.
7. The response format below has been provided.

# Response Format

```
## Summary
Brief description of what was done.

## Changed files
- `path/to/file.rb`: description of change.

## Design decisions
- decision; reason; trade-offs (note explicitly when shameless green was
  chosen over an abstraction, and why).

## Validation
- Commands executed and results obtained.
  If a command could not be run, state it here.

## Tests
- Tests added or modified.
- Scenarios covered, including error and edge cases.

## Risks and limitations
- Known risks.
- Validations that could not be executed.
- Items that depend on the external environment.

## Suggested next step
One relevant next step, only when necessary.
```

# Handling Limitations and Failures

- If the environment lacks Ruby/Bundler or the project's tools, describe
  what would be executed and why.
- If the request is ambiguous, ask one focused clarifying question before
  writing code.
- If a requested change conflicts with project conventions, explain the
  conflict and recommend preserving consistency unless there is a clear
  technical reason to deviate.
- If a task requires a significant architectural change (e.g., splitting
  a God object, introducing a new bounded-context namespace), propose an
  incremental plan rather than a single large rewrite.
- If a dependency must be added, justify the choice, confirm it's
  compatible with the project's Ruby/Rails version, and confirm a
  standard-library or already-installed alternative doesn't already cover
  it.

# Supplementary References

- [references/architecture.md](references/architecture.md)
- [references/conventions.md](references/conventions.md)
- [references/testing.md](references/testing.md)
- [references/security.md](references/security.md)
- [references/guardrails.md](references/guardrails.md)
- [references/examples.md](references/examples.md)
- [tests/scenarios.md](tests/scenarios.md)

# Guardrails

All guardrails in `../shared/guardrails.md` apply to this skill.
Ruby/Rails-specific guardrails are in `references/guardrails.md` and
extend the shared ones.

Read both before starting any task. When a rule in
`references/guardrails.md` conflicts with the shared guardrails, the
shared guardrails take precedence unless the Ruby-specific file explicitly
states otherwise.

Key Ruby/Rails guardrail areas: no class variables, no bare broad
rescues, no raw SQL interpolation, strong parameters always used, no
disabling CSRF/authentication to simplify development, secrets via Rails
credentials or environment variables (never in `config/*.yml` committed to
the repo), N+1 queries addressed with `includes`/`preload` rather than
suppressed, background jobs idempotent and retry-safe.
