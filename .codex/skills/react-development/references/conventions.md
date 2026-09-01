# React Conventions

## Naming

- **Components**: `PascalCase` — `ProductList`, `CheckoutForm`, `UserAvatar`
- **Custom hooks**: `camelCase` prefixed with `use` — `useProducts`, `useCheckout`, `useDebounce`
- **Event handlers**: `handle` prefix — `handleSubmit`, `handleFilterChange`, `handleClose`
- **Props callbacks**: `on` prefix — `onSubmit`, `onFilterChange`, `onClose`
- **Files**: match the component or hook name — `ProductList.tsx`, `useProducts.ts`
- **Test files**: `<ComponentName>.test.tsx` or `<hookName>.test.ts`
- All identifiers must be in English.
- Avoid: `data`, `info`, `item`, `component`, `wrapper` — use names that describe the UI concept.

## TypeScript

- Use TypeScript for all new components and hooks if the project uses TypeScript.
- Define prop types with `interface` or `type` co-located with the component:
  ```tsx
  interface ProductCardProps {
    product: Product;
    onSelect: (id: string) => void;
  }
  ```
- Prefer `interface` for component props (open to extension); `type` for union types and aliases.
- Do not use `any`. Use `unknown` when a type is genuinely unknown, then narrow it.
- Use `ReactNode` for children that can be any renderable content.
- Use `ReactElement` when a more specific element type is required.

## Component Structure

Order sections in a component file consistently:

1. Imports
2. Type definitions (props, local types)
3. Component function
4. (Inside component): hooks, derived state, event handlers, JSX return
5. Helper functions outside the component (pure functions, no hooks)

```tsx
import React, { useState } from 'react';

interface SearchInputProps {
  placeholder?: string;
  onSearch: (query: string) => void;
}

export function SearchInput({ placeholder = 'Search…', onSearch }: SearchInputProps) {
  const [query, setQuery] = useState('');

  function handleChange(event: React.ChangeEvent<HTMLInputElement>) {
    setQuery(event.target.value);
  }

  function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    onSearch(query);
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="search"
        value={query}
        onChange={handleChange}
        placeholder={placeholder}
        aria-label={placeholder}
      />
      <button type="submit">Search</button>
    </form>
  );
}
```

## State

- Use `useState` for simple, independent values.
- Use `useReducer` when state has multiple sub-values that change together or when next state depends on the previous state with logic.
- Never mutate state directly:
  ```tsx
  // Incorrect:
  items.push(newItem);
  setItems(items);
  
  // Correct:
  setItems([...items, newItem]);
  ```
- Never mutate nested state without creating a new object:
  ```tsx
  // Incorrect:
  user.profile.name = 'Alice';
  setUser(user);
  
  // Correct:
  setUser({ ...user, profile: { ...user.profile, name: 'Alice' } });
  ```

## Props

- Do not mutate props.
- Destructure props in the function signature for clarity.
- Use `children` only for components that are genuine container/wrapper components.
- Avoid passing too many props — if a component needs more than five or six props, consider splitting it or introducing a data object.

## useEffect

- Always declare all dependencies in the dependency array.
- Do not suppress the `exhaustive-deps` ESLint rule without a documented reason.
- Do not use `useEffect` for derived values — compute them during render.
- Do not use `useEffect` to synchronize two pieces of state — use a single state source of truth.
- Return a cleanup function when the effect creates subscriptions, timers, or DOM listeners.
- Effects run after every render by default — specify dependencies to control frequency.

## Keys

- Always provide a stable, unique `key` prop for list items.
- Do not use the array index as a key for lists that can be reordered or filtered.
- Use a business identifier (ID, slug) as the key.

## Accessibility

- Use semantic HTML elements: `<button>`, `<nav>`, `<header>`, `<main>`, `<section>`.
- Every interactive element must have an accessible name: visible label, `aria-label`, or `aria-labelledby`.
- Every image must have an `alt` attribute (empty string for decorative images).
- Form inputs must be associated with a `<label>` via `htmlFor`/`id` or `aria-label`.
- Maintain visible focus indicators — do not remove `:focus` styles.
- Keyboard users must be able to reach and activate all interactive elements.
- Use `aria-live` regions for dynamic content that should be announced to screen readers.

## Error and Loading States

Every async data operation must handle:

- **Loading**: show a loading indicator, skeleton, or disable interactive elements
- **Error**: show a user-friendly error message with a retry action when possible
- **Empty**: show a meaningful empty state, not a blank area

## Forms

- Controlled components are the default — manage form values with state.
- Use uncontrolled components (`useRef`) only for performance-sensitive large forms or file inputs.
- Validate on submit; optionally validate on blur for a better user experience.
- Show field-level error messages with `aria-describedby` linking the input to its error.

## Modern React (18+) Features

### Error Boundaries

Error Boundaries catch JavaScript errors in the component tree and display a fallback UI. They must be class components (one of the few remaining valid uses of class components):

```tsx
class ErrorBoundary extends React.Component<
  { fallback: ReactNode; children: ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError(): { hasError: boolean } {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error('Uncaught error:', error, info);
  }

  render() {
    if (this.state.hasError) return this.props.fallback;
    return this.props.children;
  }
}

// Usage:
<ErrorBoundary fallback={<p>Something went wrong.</p>}>
  <ProductList />
</ErrorBoundary>
```

Use third-party packages like `react-error-boundary` if the project already includes one — they provide a cleaner functional API.

### Suspense

`React.Suspense` shows a fallback while a lazy-loaded component or data-fetching (via React Query, Relay, etc.) is pending:

```tsx
const ProductDetail = React.lazy(() => import('./ProductDetail'));

<Suspense fallback={<LoadingSpinner />}>
  <ProductDetail id={productId} />
</Suspense>
```

Combine `Suspense` with `React.lazy` for code splitting. React Query and other libraries support Suspense mode — check the project's data fetching library before introducing Suspense for data.

### useTransition and useDeferredValue

Use for non-urgent state updates to avoid blocking the main thread:

```tsx
function SearchPage() {
  const [query, setQuery] = useState('');
  const [isPending, startTransition] = useTransition();

  function handleSearch(value: string) {
    startTransition(() => {
      setQuery(value); // non-urgent: can be interrupted
    });
  }

  return (
    <>
      <SearchInput onChange={handleSearch} />
      {isPending && <p>Updating results…</p>}
      <SearchResults query={query} />
    </>
  );
}
```

`useDeferredValue` is the hook equivalent for deferring a derived value:

```tsx
const deferredQuery = useDeferredValue(query);
// pass deferredQuery to expensive child components
```

Use these only when user-visible performance issues are confirmed by profiling — they add complexity without benefit otherwise.

### React Server Components (RSC)

If the project uses Next.js 13+ App Router or another RSC-capable framework:

- Server Components (`async function Component()`) run on the server — they can fetch data directly, access databases, and use server-only secrets.
- Client Components (`'use client'` directive) run in the browser — they handle interactivity, state, and browser APIs.
- Do not add `'use client'` to components that do not need it — keep the server boundary as high as possible.
- Do not pass non-serializable values (functions, class instances) from Server to Client Components.

```tsx
// Server Component — no 'use client', can await data:
async function ProductPage({ id }: { id: string }) {
  const product = await fetchProduct(id); // direct server-side fetch
  return <ProductDetail product={product} />;
}

// Client Component — interactivity:
'use client';
function AddToCartButton({ productId }: { productId: string }) {
  const [added, setAdded] = useState(false);
  return <button onClick={() => setAdded(true)}>{added ? 'Added' : 'Add to cart'}</button>;
}
```

## Patterns to Avoid

- Direct DOM manipulation (`document.getElementById`, `document.querySelector`) when a React approach exists
- Mutating state or props
- `useEffect` for synchronizing two pieces of state
- `useEffect` for derived calculations
- Missing keys in lists
- Memoization (`useMemo`, `useCallback`) without a profiler-confirmed performance problem
- Index as list key in dynamic lists
- Global state for local concerns
- Context re-renders: splitting large contexts into smaller, focused ones avoids unnecessary re-renders
- Business logic in JSX expressions
- Inline anonymous functions as props where referential equality matters (extract to named handlers)
