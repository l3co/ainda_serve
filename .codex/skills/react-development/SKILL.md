---
name: react-development
description: Guides agents in developing, reviewing, refactoring, and evolving React applications with functional components, hooks, composition, and user-centric testing. Activate for any task in a React codebase — components, hooks, state management, forms, routing, accessibility, or testing.
---

# Objective

Guide agents to produce correct, maintainable, accessible React code that respects existing project conventions, uses hooks and composition idiomatically, and applies the simplest design that solves the real problem without premature abstraction.

# Fundamental Principles

- Functional components and hooks — no class components in new code
- Composition over inheritance — components are composed, not extended
- UI as a function of state — no direct DOM manipulation
- Never mutate state or props directly
- Separate concerns: rendering, state management, business logic, data fetching
- Accessible by default — semantic HTML, ARIA where needed, keyboard navigation
- Test from the user's perspective, not from the component's internal structure
- Start small and cohere; extract only when there is a clear benefit

# When to Use

- Creating new React components or pages
- Implementing or refactoring custom hooks
- Managing state with `useState`, `useReducer`, context, or external state libraries
- Fixing bugs in React rendering, event handling, or side effects
- Writing or extending React Testing Library tests
- Reviewing React code for design problems, hook misuse, or accessibility issues
- Integrating data fetching, routing, or form handling
- Improving performance (memoization, code splitting, lazy loading)

# When Not to Use

- The project uses a different frontend framework (Vue, Angular, Svelte) even if it renders to the same page
- The task is purely about backend APIs, CI/CD, or infrastructure with no React code changes
- The task is about the build configuration only (webpack, Vite, tsconfig) with no component changes

# Expected Inputs

- A clear description of the task or problem
- Access to the project source tree and configuration (`package.json`, `tsconfig.json`, etc.)
- The React version and TypeScript/JavaScript choice
- Existing component patterns, styling approach, and test conventions
- State management libraries in use (Redux, Zustand, Jotai, React Query, SWR, etc.)
- Routing library (React Router, TanStack Router, Next.js, etc.)
- Testing setup (React Testing Library, Vitest, Jest, Playwright, Cypress)

# Execution Process

1. Read the full request before taking any action.
2. Inspect the project: directory structure, `package.json`, key dependencies.
3. Identify React version, TypeScript usage, and styling approach.
4. Find similar components or hooks in the codebase to align with established patterns.
5. Identify existing state management and data fetching conventions.
6. Separate explicit requirements from assumptions.
7. Identify risks, ambiguities, and missing information.
8. Choose the simplest correct implementation that addresses the problem.
9. Formulate a small, verifiable plan before writing code.
10. Implement components and hooks with clear responsibility boundaries.
11. Ensure accessibility: semantic HTML, ARIA attributes where needed, keyboard support.
12. Add or update tests using React Testing Library, focusing on user interactions.
13. Run the type checker (`tsc --noEmit`) if TypeScript is used.
14. Run `eslint` on changed files if configured.
15. Run the test suite (`npm test`, `vitest run`, etc.).
16. Verify rendering and behavior in a browser when the environment allows.
17. Review the final diff for unintended changes.
18. Present results using the standard response format.

# Mandatory Rules

- All component names, hook names, function names, and variable names must be in English.
- Test descriptions and query labels must be in English.
- Never mutate state directly — always use the setter from `useState` or dispatch from `useReducer`.
- Never mutate props — treat props as read-only.
- Always specify dependencies in `useEffect`, `useMemo`, and `useCallback` dependency arrays. Do not suppress the exhaustive-deps ESLint rule without a documented reason.
- Never use `useEffect` for derived state — compute derived values during render.
- Do not use `useEffect` for event handling that can be done with event handlers.
- Keep components small and focused — a component should render one primary concept.
- Extract a custom hook when logic involves state or effects and could be reused or tested independently.
- Do not use the index as a React list key when items can be reordered or filtered.
- Never access DOM nodes directly when a React approach is available.
- Do not add global state for data that is only needed locally.

# Architecture and Organization

See [references/architecture.md](references/architecture.md) for detailed guidance.

Organize by feature or domain. Co-locate tests, styles, and types with their components. Separate data fetching from rendering using hooks or query libraries.

# Language Conventions

See [references/conventions.md](references/conventions.md) for detailed React/TypeScript conventions.

# Testing Strategy

See [references/testing.md](references/testing.md) for the complete testing approach.

Test from the user's perspective using React Testing Library. Query by role, label, or text — not by implementation details like class names or component internals.

# Mandatory Validations

Before declaring a task complete, confirm:

- [ ] `tsc --noEmit` reports no new errors (if TypeScript)
- [ ] `eslint` reports no new errors on changed files
- [ ] Test suite passes
- [ ] No direct state mutation introduced
- [ ] No missing `useEffect` dependencies introduced
- [ ] No list keys using array indices in dynamic lists
- [ ] No hardcoded secrets, API keys, or credentials
- [ ] Accessible: interactive elements have accessible names

If any validation cannot be executed, declare it explicitly under "Risks and limitations."

# Completion Criteria

A task is complete when:

1. The requested behavior is correctly implemented and verified.
2. Existing tests continue to pass.
3. New tests cover user-visible behavior including error states.
4. Components are accessible and follow project conventions.
5. TypeScript types are correct if the project uses TypeScript.
6. The diff is minimal and focused.
7. The response format has been provided.

# Response Format

```
## Summary
Brief description of what was done.

## Changed files
- `src/components/ProductList.tsx`: description of change.

## Design decisions
- decision; reason; trade-offs.

## Validation
- Commands executed and results obtained.
  If a command could not be run, state it here.

## Tests
- Tests added or modified.
- Scenarios covered: render, interaction, error states, accessibility.

## Risks and limitations
- Known risks.
- Validations that could not be executed.
- Items that require manual browser testing.

## Suggested next step
One relevant next step, only when necessary.
```

# Handling Limitations and Failures

- If the environment lacks the Node.js runtime or dev server, describe what would be run.
- If visual verification in a browser is not possible, state this and describe what manual testing should cover.
- If the request is ambiguous, ask one focused clarifying question before writing code.
- If a change conflicts with project conventions, explain the conflict and recommend consistency.
- If performance optimization is requested, measure first — do not optimize without evidence of a real problem.

# Supplementary References

- [references/architecture.md](references/architecture.md)
- [references/conventions.md](references/conventions.md)
- [references/testing.md](references/testing.md)
- [references/security.md](references/security.md)
- [references/guardrails.md](references/guardrails.md)
- [references/examples.md](references/examples.md)
- [tests/scenarios.md](tests/scenarios.md)

# Guardrails

All guardrails in `../shared/guardrails.md` apply to this skill. React-specific guardrails are in `references/guardrails.md` and extend the shared ones.

Read both before starting any task. When a rule in `references/guardrails.md` conflicts with the shared guardrails, the shared guardrails take precedence unless the React-specific file explicitly states otherwise.

Key React guardrail areas: functional components only, no direct state mutation, stable `key` props in lists, no global state for local data, `useEffect` dependencies complete, cleanup on unmount, `ErrorBoundary` + `Suspense` for async trees, no `dangerouslySetInnerHTML` with unescaped input, no secrets in client bundles, accessible markup.
