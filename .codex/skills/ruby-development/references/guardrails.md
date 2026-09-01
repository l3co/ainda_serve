# Ruby/Rails Guardrails

These extend `../shared/guardrails.md`. Where a rule here conflicts with
the shared file, the shared file wins unless this file explicitly says
otherwise (see `SKILL.md`).

---

## Architecture Protection (Ruby/Rails-specific)

MUST NOT create a service object (`XyzService`) that only delegates to a
model method — put the behavior on the model instead (see
`references/architecture.md`).

MUST NOT introduce a state-machine gem (AASM or similar) for a model with
a handful of states and simple guard-clause transitions.

MUST NOT add Devise, Pundit, CanCanCan, or a comparable heavyweight gem
before Rails' own scaffold (`has_secure_password`, a `before_action`
ownership check) has demonstrably become insufficient for the project.

MUST NOT create a namespace/module for a single class with no sibling
classes that justify the grouping.

MUST NOT replace ActiveRecord callbacks that reach into another model with
more callbacks — extract the "collect and dispatch" domain-event pattern
instead once a state change needs to trigger more than one unrelated side
effect.

MUST NOT model a cross-context workflow as one large coordinating object
that performs several unrelated writes — prefer a domain event with
independent subscribers, each owning one write.

---

## Dependency Protection (Ruby/Rails-specific)

MUST NOT add a gem for something Ruby's standard library or Rails already
provides (e.g., an HTTP client gem for a single simple API call `Net::HTTP`
already handles cleanly; a JSON serializer gem when `as_json`/`jbuilder`
is sufficient for the API surface in question).

MUST NOT add a gem to reach feature parity with a pattern from another
framework/language when it isn't idiomatic Rails — port the intent, not
the machinery.

MUST verify a new gem's Ruby/Rails version compatibility against the
project's `Gemfile.lock` before adding it, and run `bundle install`
(never hand-edit `Gemfile.lock`).

MUST justify every new gem in the final response, including why the
standard library or an already-installed gem doesn't already cover the
need.

---

## Code Integrity (Ruby/Rails-specific)

MUST NOT use class variables (`@@foo`).

MUST NOT rescue `StandardError` or `Exception` broadly without a
documented reason and a narrower rescue where the actual failure mode is
known.

MUST NOT use `method_missing` where a normal method, `Data.define`, or
`Struct` would work.

MUST NOT monkey-patch a class the project doesn't own without a
documented reason.

MUST NOT introduce `case obj when SomeClass` / `is_a?` branching where a
polymorphic method on the object(s) in question would do — see
`references/conventions.md`.

MUST NOT leave an empty `rescue => e; end` (or equivalent) that discards
an exception without logging, re-raising, or otherwise handling it.

---

## Database and Persistence (Ruby/Rails-specific)

MUST NOT write a migration that mixes a destructive change (dropping a
column/table) with the deploy that stops using it — split into "stop
using it," then "drop it" once the first has shipped safely.

MUST NOT bypass ActiveRecord validations (`update_column`,
`update_all`, `save(validate: false)`) without a documented reason — these
skip callbacks and validations silently.

MUST NOT add a database index migration without checking whether an
equivalent index already exists.

MUST NOT introduce raw SQL string interpolation — see
`references/security.md`.

---

## Testing Integrity (Ruby/Rails-specific)

MUST NOT make a real HTTP request to a third-party API in a unit, model,
or request spec — stub with `WebMock`/`VCR`.

MUST NOT write a system spec (`js: true`) for a flow that doesn't actually
depend on Turbo/Stimulus behavior — a plain full-page-redirect form
submission belongs in a faster request spec.

MUST NOT use `sleep` to wait for asynchronous behavior in a system spec —
Capybara's built-in waiting matchers already handle this correctly.

MUST NOT share mutable state (a module-level constant, a class variable)
between test examples in a way that makes test order matter.

---

## Security (Ruby/Rails-specific)

See `references/security.md` for the full list. The non-negotiable
subset, restated here because it's the most commonly violated:

MUST use strong parameters for every mass-assigned model.

MUST NOT disable CSRF protection, mass-assignment protection, or
authentication to make a controller easier to call in development or
tests.

MUST NOT use `html_safe`/`raw` on content derived from user input without
an explicit sanitization step.

MUST use `Rails.application.credentials` or environment variables for
secrets — never a plaintext value in a committed YAML file.

---

## Portability (Ruby/Rails-specific)

MUST NOT assume a specific Ruby version manager (`rbenv`, `asdf`, `rvm`) —
respect whatever `.tool-versions`/`.ruby-version` the project declares
without assuming the tool that manages it.

MUST NOT assume Bundler is configured for a specific `BUNDLE_PATH` — use
the project's existing Bundler configuration.

MUST NOT assume a specific Rails asset pipeline (Sprockets, Propshaft,
esbuild/importmap) beyond what the project already uses.
