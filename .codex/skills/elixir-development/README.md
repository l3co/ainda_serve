# Elixir Development Skill

## Purpose

This skill guides agents in producing correct, idiomatic Elixir code. It covers functional programming patterns, OTP (Open Telecom Platform) design, Phoenix web applications, Ecto data layer, ExUnit testing, and the conventions of the Elixir ecosystem.

## Task Types

This skill activates for:

- New modules, GenServers, Supervisors, and OTP application trees
- Phoenix controllers, LiveViews, channels, router changes, and plugs
- Ecto schemas, changesets, queries, migrations, and Repo interactions
- ExUnit test suites and doctests
- Mix tasks and configuration changes
- Code review of Elixir modules for idiom, correctness, and security
- Refactoring towards more idiomatic functional or OTP patterns
- Performance investigation in process-heavy or query-heavy code

## Limits

This skill does not:

- Recommend Erlang-only solutions when an Elixir-idiomatic alternative exists
- Use class-based or inheritance patterns (Elixir has none)
- Create processes where a function call would suffice
- Apply OTP patterns without a concrete fault-isolation or concurrency need
- Make architectural decisions that involve multiple independent applications without guidance
- Assume the presence of Phoenix, Ecto, or any library not evident in the project

## Activation Examples

- "Add a GenServer to cache product prices with a TTL"
- "Write an Ecto changeset for user registration with email and password validation"
- "Implement a Phoenix LiveView for a real-time order tracking page"
- "Refactor this module to use the pipe operator"
- "Write ExUnit tests for the discount calculation module"
- "Add a Supervisor to the OTP tree for the notification worker"
- "Review this Ecto query for N+1 issues and security risks"
- "Add structured logging to the payment processing flow"
