# ruby-development skill

## Purpose

This skill guides programming agents to develop, review, refactor, and
evolve Ruby and Rails projects with idiomatic style and the object-design
philosophy of *99 Bottles of OOP* (Sandi Metz, Katrina Owen): small,
single-responsibility objects; concrete solutions before abstract ones;
duck typing over type checks; abstraction earned by repetition (the Rule
of Three) rather than predicted in advance. It covers plain Ruby as well
as Rails — models, controllers, jobs, and Hotwire (Turbo/Stimulus) views —
adapting to whatever the project actually uses rather than forcing a
specific stack.

## Task Types

This skill applies when an agent must:

- Implement new features or classes in a Ruby or Rails project
- Fix bugs in Ruby or Rails code
- Write or extend RSpec or Minitest tests
- Refactor Ruby/Rails code for clarity, testability, or idiomatic
  correctness — including splitting God objects, replacing `case`/`is_a?`
  branching with polymorphism, or extracting a plain Ruby object out of an
  overloaded ActiveRecord model
- Review Ruby/Rails code for object-design problems, security issues, or
  premature abstraction
- Evaluate or propose architecture for a Ruby/Rails project
- Work on Hotwire (Turbo Frames/Streams, Stimulus) front-end behavior
  inside a Rails app

## How to Use

Load `SKILL.md` at the start of any Ruby task. It defines the execution
process, mandatory rules, validation checklist, and response format.

Supplementary files in `references/` provide deeper guidance for
architecture, conventions, testing, and code examples.
`tests/scenarios.md` contains evaluation scenarios.

## Complementary Files

| File | Purpose |
|------|---------|
| [SKILL.md](SKILL.md) | Core skill definition — load this first |
| [references/architecture.md](references/architecture.md) | Rails app layout, where behavior belongs, the domain-event pattern |
| [references/conventions.md](references/conventions.md) | Ruby naming/style and Rails-specific conventions (ActiveRecord, controllers, Hotwire) |
| [references/testing.md](references/testing.md) | Testing strategy with RSpec/Minitest, FactoryBot, and Hotwire system specs |
| [references/security.md](references/security.md) | Ruby/Rails-specific security guidance |
| [references/guardrails.md](references/guardrails.md) | Hard limits extending the shared guardrails |
| [references/examples.md](references/examples.md) | Short idiomatic Ruby/Rails code examples for reference |
| [tests/scenarios.md](tests/scenarios.md) | Validation scenarios to evaluate skill correctness |

## Key Limits

- This skill does not cover non-Ruby files in a project (JS beyond
  Stimulus, SQL run outside ActiveRecord, YAML, Dockerfiles).
- It does not force Rails on a plain Ruby project, or a specific Rails
  front end (Hotwire vs. an API-only Rails app serving a separate SPA) —
  it adapts to what the project uses, while still applying the same
  object-design principles either way.
- It does not replace human review for security-critical changes.
- It does not guarantee test execution in every environment — gaps must
  be declared explicitly.

## Examples of Requests That Should Activate This Skill

- "Add a `finish_reading` method to this ActiveRecord model."
- "This controller has a 40-line action with three levels of `if` — clean
  it up."
- "Write RSpec tests for the SM-2 scheduling calculation."
- "Should this be a service object or a method on the model?"
- "Refactor this `case status when ...` into polymorphism."
- "Add a Turbo Stream broadcast when a club message is created."
- "Review this Rails migration and model for N+1 query risk."

## Examples of Requests That Should NOT Activate This Skill

- "Write a Python script to migrate this data." (different language)
- "Set up the GitHub Actions workflow YAML." (no Ruby code changes)
- "Review the Stimulus... actually this is a plain JS utility with no
  Rails/Ruby involvement." (pure JS, not Ruby)
- "Configure the Railway Dockerfile." (infrastructure only, unless it
  changes how Ruby code is built/run)
