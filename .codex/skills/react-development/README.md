# react-development skill

## Purpose

This skill guides programming agents to develop, review, refactor, and evolve React applications with functional components, hooks, composition, accessibility, and user-centric testing. It emphasizes simplicity, correct hook usage, and tests that interact with components the way a real user would.

## Task Types

This skill applies when an agent must:

- Create new React components, pages, or layouts
- Implement or refactor custom hooks
- Manage state with React primitives or external libraries
- Fix bugs in rendering, event handling, or side effects
- Write or extend React Testing Library tests
- Review React code for design problems, hook misuse, or accessibility issues
- Integrate data fetching, routing, or form handling
- Improve performance or reduce bundle size

## How to Use

Load `SKILL.md` at the start of any React task. It defines the execution process, mandatory rules, validation checklist, and response format.

Supplementary files in `references/` provide deeper guidance for architecture, conventions, testing, and code examples. `tests/scenarios.md` contains evaluation scenarios.

## Complementary Files

| File | Purpose |
|------|---------|
| [SKILL.md](SKILL.md) | Core skill definition — load this first |
| [references/architecture.md](references/architecture.md) | Component architecture and organization guidance |
| [references/conventions.md](references/conventions.md) | React and TypeScript naming and code conventions |
| [references/testing.md](references/testing.md) | Testing strategy with React Testing Library |
| [references/examples.md](references/examples.md) | Short idiomatic React/TypeScript code examples |
| [tests/scenarios.md](tests/scenarios.md) | Validation scenarios to evaluate skill correctness |

## Key Limits

- This skill does not cover server-side code, API routes, or database logic.
- It does not force a specific state management library — it adapts to what the project uses.
- Visual testing in a browser cannot be automated in all environments — gaps must be declared.
- It does not cover non-React frontend frameworks (Vue, Angular, Svelte).

## Examples of Requests That Should Activate This Skill

- "Add a loading state to the product list component."
- "Fix the stale closure bug in this useEffect."
- "Write React Testing Library tests for the checkout form."
- "Extract this state logic into a custom hook."
- "Add keyboard navigation support to the dropdown menu."
- "Review this component for accessibility issues."
- "Why is this component re-rendering on every keystroke?"

## Examples of Requests That Should NOT Activate This Skill

- "Write a Python script to process this data."
- "Create the Express API for this form submission."
- "Write an Angular component for this feature."
- "Set up the Webpack configuration."
- "Review the Go service that handles this endpoint."
