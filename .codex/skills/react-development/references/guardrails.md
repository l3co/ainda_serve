# React-Specific Guardrails

These guardrails apply to all agents working on React codebases. They extend — not replace — the shared guardrails in `../shared/guardrails.md`. In any conflict, the shared guardrails take precedence unless noted here.

---

## Component Design

MUST use functional components — not class components for new code.

MUST NOT use class components unless maintaining existing code that cannot be migrated without significant risk.

MUST NOT create components that manage unrelated concerns in the same function.

MUST NOT pass more than 5 props to a component without evaluating whether composition or context would be cleaner.

MUST NOT expose internal state from a child to a parent via refs unless `useImperativeHandle` is explicitly justified.

MUST NOT render a list without a stable, unique `key` prop — never use the array index as key in dynamic lists.

---

## State Management

MUST NOT use global state for data that is local to one component tree.

MUST NOT put UI state (modal open/close, form input values) in a global store.

MUST NOT mutate state directly — always produce a new object or array.

MUST NOT call the state setter with a value derived from the previous state without using the functional updater form (`setState(prev => ...)`).

SHOULD derive values during render rather than synchronizing them via `useEffect`.

MUST NOT use `useEffect` to synchronize two pieces of local state that should be one.

---

## Hooks

MUST call hooks only at the top level of a component or custom hook — never inside loops, conditions, or event handlers.

MUST NOT call hooks from regular (non-component, non-hook) functions.

MUST include all values referenced inside a `useEffect` in the dependency array unless deliberately omitted with a documented reason.

MUST add a cleanup function to `useEffect` when it creates subscriptions, timers, or event listeners.

MUST NOT use `useRef` to hold mutable state that should trigger a re-render — use `useState`.

SHOULD extract complex logic from `useEffect` into a named function for readability.

---

## Side Effects and Data Fetching

MUST NOT perform data fetching directly in a component body — use a hook, a library query, or a Server Component.

MUST handle cancelled requests when a component unmounts during a fetch — use an `isCancelled` flag or `AbortController`.

MUST handle loading and error states explicitly — do not assume data is always available.

MUST NOT fire network requests based on unvalidated user input without debouncing or validation.

MUST NOT expose internal API errors directly in the UI — show a user-friendly message.

---

## Forms and Validation

MUST NOT rely solely on frontend validation — assume the server validates independently.

MUST NOT submit a form without preventing the default browser action (`event.preventDefault()`).

MUST manage form state in a controlled manner — do not mix controlled and uncontrolled inputs for the same field.

MUST associate `<label>` with its input using `htmlFor` and matching `id` — not just visual proximity.

MUST provide accessible error messages using `aria-describedby` and `role="alert"`.

---

## Error Boundaries and Suspense

MUST wrap async component trees (data-fetching, lazy-loaded routes) with both an `ErrorBoundary` and `Suspense`.

MUST provide a fallback with a meaningful `role` attribute (`role="alert"` for errors, `role="status"` for loading).

MUST NOT use `console.error` inside `onError` as the sole error-reporting mechanism in production.

MUST NOT place a single `ErrorBoundary` at the root only — use granular boundaries so one failure does not take down the whole page.

---

## TypeScript

MUST NOT use `any` as a type for component props.

MUST define an explicit interface or type alias for every component's props.

MUST NOT use type assertions (`as X`) to bypass TypeScript on data whose shape is unknown — validate the shape first.

MUST NOT suppress TypeScript errors with `@ts-ignore` without a comment explaining why.

SHOULD prefer `unknown` over `any` when the shape is genuinely unknown, then narrow with guards.

---

## Accessibility

MUST use semantic HTML elements (`<button>`, `<nav>`, `<main>`, `<article>`) instead of generic `<div>` with click handlers.

MUST NOT use `onClick` on a non-interactive element without also adding `role`, `tabIndex`, and keyboard event handling.

MUST provide `alt` text for all `<img>` elements — use `alt=""` for decorative images.

MUST NOT remove focus outlines without replacing them with an equivalent visible focus indicator.

SHOULD test keyboard navigation for all interactive flows.

---

## Security (React-Specific)

MUST NOT use `dangerouslySetInnerHTML` with unescaped user-provided content.

When `dangerouslySetInnerHTML` is necessary, MUST sanitize the content using a trusted library (e.g., DOMPurify) before rendering.

MUST NOT build URLs or redirects from raw user input without validation.

MUST NOT store sensitive data (tokens, personal identifiers) in `localStorage` or `sessionStorage` without evaluating the XSS risk.

MUST NOT embed secrets or API keys in client-side bundle code.

MUST use HTTPS for all external resource URLs.

MUST NOT log form values, payloads, or user input to the console in production builds.

---

## Performance

MUST NOT wrap every function in `useCallback` or every value in `useMemo` without profiling evidence.

MUST NOT use `React.memo` as a default — apply it only when profiling confirms unnecessary re-renders.

MUST NOT create new object or array literals in JSX props when they trigger unnecessary child re-renders.

SHOULD lazy-load routes and heavy components using `React.lazy` and `Suspense`.

MUST NOT import entire libraries when only a subset is needed — prefer named imports.

---

## Observability

MUST NOT use `console.log` for production tracing — use the project's tracing or monitoring library.

SHOULD capture uncaught errors from `ErrorBoundary.onError` with a monitoring service.

MUST NOT expose internal component state or Redux state in console output in production builds.

SHOULD use `useTransition` or `useDeferredValue` to avoid blocking the UI during non-urgent state updates.
