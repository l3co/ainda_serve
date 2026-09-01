# React Testing Strategy

## Philosophy

Test components from the user's perspective — what the user sees and interacts with — not from the component's internal structure. A test that breaks when you rename a CSS class is testing the wrong thing. A test that breaks when the visible label or behavior changes is doing its job.

## Framework Baseline

- **React Testing Library** for component tests — it encourages accessibility-first queries.
- **Jest** or **Vitest** as the test runner.
- **@testing-library/user-event** for simulating realistic user interactions.
- **Playwright** or **Cypress** for end-to-end tests (when present in the project).
- Do not introduce new testing libraries without justification.

## Query Priority

React Testing Library queries, from most to least preferred:

1. `getByRole` — the most semantically correct: `getByRole('button', { name: 'Submit' })`
2. `getByLabelText` — for form inputs: `getByLabelText('Email address')`
3. `getByPlaceholderText` — secondary for inputs without a label
4. `getByText` — for non-interactive text content
5. `getByDisplayValue` — for filled form fields
6. `getByTestId` — last resort; use only when no semantic query applies

Do not query by class name, component display name, or internal prop values. These break when you refactor without changing behavior.

## Component Tests

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ProductCard } from './ProductCard';

describe('ProductCard', () => {
  it('renders the product name and price', () => {
    render(<ProductCard name="Notebook" priceInCents={1999} onSelect={jest.fn()} />);

    expect(screen.getByText('Notebook')).toBeInTheDocument();
    expect(screen.getByText('$19.99')).toBeInTheDocument();
  });

  it('calls onSelect with the product id when the select button is clicked', async () => {
    const handleSelect = jest.fn();
    render(<ProductCard id="prod-1" name="Notebook" priceInCents={1999} onSelect={handleSelect} />);

    await userEvent.click(screen.getByRole('button', { name: 'Select Notebook' }));

    expect(handleSelect).toHaveBeenCalledWith('prod-1');
  });
});
```

## Integration Tests

Integration tests verify that a group of components and hooks work together correctly:

```tsx
it('shows filtered products when the user types in the search input', async () => {
  render(<ProductsPage />);

  await userEvent.type(screen.getByLabelText('Search products'), 'note');

  expect(screen.getByText('Notebook')).toBeInTheDocument();
  expect(screen.queryByText('Headphones')).not.toBeInTheDocument();
});
```

Mock only the network boundary (API calls), not component internals:

```tsx
import { http, HttpResponse } from 'msw';
import { server } from '../../test/server';

beforeEach(() => {
  server.use(
    http.get('/api/products', () =>
      HttpResponse.json([{ id: '1', name: 'Notebook', priceInCents: 1999 }])
    )
  );
});
```

Use **Mock Service Worker (MSW)** to intercept HTTP requests — it is the closest to real network behavior.

## Custom Hook Tests

Test custom hooks using `renderHook` from React Testing Library:

```tsx
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

it('increments the counter when increment is called', () => {
  const { result } = renderHook(() => useCounter(0));

  act(() => {
    result.current.increment();
  });

  expect(result.current.count).toBe(1);
});
```

## End-to-End Tests

End-to-end tests verify complete user flows in a real or staging browser:

- Use for critical paths: login, checkout, form submission, navigation
- Do not use for every component behavior — that belongs in component tests
- Prefer stable selectors: `getByRole`, `aria-label`, `data-testid` as a last resort
- Run E2E tests in CI against a deployed preview environment, not `localhost` (when possible)

## Accessibility Tests

```tsx
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

it('has no accessibility violations', async () => {
  const { container } = render(<CheckoutForm onSubmit={jest.fn()} />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

Use `jest-axe` or equivalent for automated accessibility checks in component tests.

## Test Doubles

- **Mock functions** (`jest.fn()`): for callbacks, event handlers, and simple service stubs
- **MSW**: for HTTP requests — always prefer this over mocking `fetch` directly
- **Context providers**: wrap components in the necessary providers in test setup

Do not mock React hooks or React itself. Test the component behavior, not which hooks it calls.

## Naming

Test names must be in English and describe a user-visible behavior:

```
renders the product name and price
shows an error message when the form is submitted without an email
calls onSelect with the product id when the select button is clicked
displays a loading spinner while products are being fetched
shows "No products found" when the search returns no results
```

Avoid: `test renders`, `component works`, `it should work`.

## What to Test

Prioritize:

- User interactions: clicks, typing, form submission, keyboard navigation
- Conditional rendering: loading states, error states, empty states, success states
- Accessible names and roles of interactive elements
- Form validation error messages
- Navigation behavior
- Regressions

Do not test:

- Which React hooks a component uses internally
- Component internal state values directly
- CSS class names
- Prop types (TypeScript handles that)
- Third-party library behavior

## Async Behavior

Use `waitFor` or `findBy*` queries for async updates:

```tsx
it('shows products after loading completes', async () => {
  render(<ProductList />);

  expect(screen.getByText('Loading…')).toBeInTheDocument();

  expect(await screen.findByText('Notebook')).toBeInTheDocument();
  expect(screen.queryByText('Loading…')).not.toBeInTheDocument();
});
```

## Running Tests

```sh
npm test                           # Jest watch mode
npm test -- --watchAll=false       # single run
npm test -- --coverage             # with coverage
vitest                             # Vitest watch mode
vitest run                         # single run
vitest run --coverage              # with coverage
npx playwright test                # E2E tests
```
