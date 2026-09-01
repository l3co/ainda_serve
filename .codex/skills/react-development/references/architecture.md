# React Architecture Guidance

## Minimal Starting Point

Start every React feature with the simplest component structure that renders correctly and passes tests. A single component file is a valid starting point. Extract sub-components, custom hooks, or shared utilities only when real complexity demands it.

Before extracting a component, hook, or context, ask:

- Is there a genuine responsibility boundary being crossed?
- Will this be reused in two or more places?
- Does the extraction improve readability or testability?
- Does it map to a meaningful concept for the user or domain?
- Would a simpler approach be insufficient?

## Component Decomposition

A component should render one primary concept. It becomes a candidate for extraction when:

- It has its own independent state and behavior
- It is reused in two or more places
- It has grown complex enough that its internals distract from the parent component's purpose
- It can be tested and reasoned about in isolation
- Splitting it reveals a clearer name for each part

Do not split components mechanically into "atoms", "molecules", and "organisms" unless your team has a clear, established Atomic Design practice.

## Project Structure

### Small projects

```
src/
├── components/
│   ├── ProductList.tsx
│   ├── ProductCard.tsx
│   └── SearchInput.tsx
├── hooks/
│   └── useProducts.ts
├── pages/
│   └── ProductsPage.tsx
└── api/
    └── productsApi.ts
```

### Feature-based structure (preferred as project grows)

```
src/
├── features/
│   ├── products/
│   │   ├── ProductList.tsx
│   │   ├── ProductCard.tsx
│   │   ├── useProducts.ts
│   │   ├── productsApi.ts
│   │   ├── productsSlice.ts     (if using Redux)
│   │   └── ProductList.test.tsx
│   └── checkout/
│       ├── CheckoutForm.tsx
│       └── useCheckout.ts
├── shared/
│   ├── components/
│   │   └── Button.tsx
│   └── hooks/
│       └── useDebounce.ts
└── pages/
    └── ProductsPage.tsx
```

Co-locate tests, styles, and types with the component they belong to.

## Separation of Concerns

Keep distinct concerns in distinct units:

- **Rendering**: what the component displays, based on props and state
- **State management**: what data is held and how it changes (local state, reducer, or external store)
- **Data fetching**: how data arrives from the server (React Query, SWR, fetch in a hook, etc.)
- **Business logic**: calculations and transformations that do not depend on React (pure functions, extractable to non-React modules)
- **Side effects**: subscriptions, timers, DOM measurements (isolated in `useEffect`)

Do not put business calculations in JSX expressions. Extract them to functions.

## Custom Hooks

Extract a custom hook when:

- State and effects are tightly coupled and would be reused
- The logic is complex enough to warrant testing independently
- The component itself would become cleaner without the logic inline

A hook should have a single purpose. `useFetchProducts` is clear. `useEverythingAboutProducts` is not.

```
useProducts.ts         — fetches and returns the product list
useProductFilters.ts   — manages filter state and derived filter params
useProductDetail.ts    — fetches a single product by ID
```

## State Management

Choose state management proportionate to the actual need:

| Data scope | Preferred approach |
|---|---|
| Component-local | `useState` or `useReducer` |
| Shared between siblings | Lift state to the nearest common ancestor |
| Cross-feature data, global UI state | Context, Redux, Zustand, Jotai, or equivalent |
| Server state (async data) | React Query, SWR, or RTK Query |

Do not use global state for data that a single component or a sibling pair owns. Do not use local state for data that multiple unrelated parts of the application need.

## Data Fetching

- Keep data fetching out of components. Fetch inside custom hooks or query library hooks.
- Handle loading, error, and empty states for every async operation.
- Do not `await` in render functions or directly in component bodies — use effects or query hooks.

## Performance

Do not optimize prematurely:

- `useMemo` and `useCallback` have a cost. Use them when a profiler confirms a real performance problem.
- `React.memo` is useful for components that re-render expensively with the same props.
- Code splitting with `React.lazy` is useful for large routes or feature bundles.
- Measure first. Perceived performance issues are sometimes rendering bugs, not true performance problems.

## When to Apply Clean Architecture

Applying Clean Architecture (separating domain logic into pure functions and models, with adapters for React and HTTP) is worthwhile when:

- The domain logic is substantial and needs to be tested independently of React
- The same business logic is shared between a React frontend and a server-side rendered or non-React context
- The team is large enough that clear dependency rules matter

For most React applications, clear component decomposition and custom hooks for state and effects provide sufficient separation without full Clean Architecture overhead.

## Criteria Against Premature Abstraction

Do not create:

- A generic `useQuery` hook when React Query or SWR already provides one
- A context provider for data that two sibling components could share through a parent
- A custom routing abstraction when the routing library covers the use case
- A UI component library before three or more usages of a pattern exist
- A generic form framework when one or two forms exist
