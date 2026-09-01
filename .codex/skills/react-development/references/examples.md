# React Idiomatic Examples

Short, focused examples. Not a complete application — reference patterns only.

---

## Functional Component with Props

```tsx
interface ProductCardProps {
  id: string;
  name: string;
  priceInCents: number;
  onSelect: (id: string) => void;
}

export function ProductCard({ id, name, priceInCents, onSelect }: ProductCardProps) {
  const formattedPrice = formatCurrency(priceInCents);

  function handleSelect() {
    onSelect(id);
  }

  return (
    <article>
      <h3>{name}</h3>
      <p>{formattedPrice}</p>
      <button type="button" onClick={handleSelect} aria-label={`Select ${name}`}>
        Select
      </button>
    </article>
  );
}

function formatCurrency(cents: number): string {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(cents / 100);
}
```

---

## Custom Hook for Data Fetching

```tsx
interface UseProductsResult {
  products: Product[];
  isLoading: boolean;
  error: string | null;
}

function useProducts(categoryId: string): UseProductsResult {
  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetch() {
      setIsLoading(true);
      setError(null);
      try {
        const data = await fetchProductsByCategory(categoryId);
        if (!cancelled) {
          setProducts(data);
        }
      } catch {
        if (!cancelled) {
          setError('Failed to load products. Please try again.');
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    }

    fetch();
    return () => { cancelled = true; };
  }, [categoryId]);

  return { products, isLoading, error };
}
```

---

## Form with Controlled Inputs

```tsx
interface SearchFormProps {
  onSearch: (query: string) => void;
}

export function SearchForm({ onSearch }: SearchFormProps) {
  const [query, setQuery] = useState('');
  const [error, setError] = useState<string | null>(null);

  function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    if (!query.trim()) {
      setError('Search query is required.');
      return;
    }
    setError(null);
    onSearch(query.trim());
  }

  return (
    <form onSubmit={handleSubmit} noValidate>
      <label htmlFor="search-input">Search products</label>
      <input
        id="search-input"
        type="search"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        aria-describedby={error ? 'search-error' : undefined}
        aria-invalid={error !== null}
      />
      {error && (
        <span id="search-error" role="alert">
          {error}
        </span>
      )}
      <button type="submit">Search</button>
    </form>
  );
}
```

---

## Correct State Update (No Mutation)

```tsx
// Incorrect — mutating the array in place:
function addItem(item: Item) {
  items.push(item); // mutation!
  setItems(items);
}

// Correct — creating a new array:
function addItem(item: Item) {
  setItems((prev) => [...prev, item]);
}

// Correct — updating a nested object:
function updateUserName(name: string) {
  setUser((prev) => ({ ...prev, profile: { ...prev.profile, name } }));
}
```

---

## React Testing Library Test

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { SearchForm } from './SearchForm';

describe('SearchForm', () => {
  it('calls onSearch with the trimmed query when submitted', async () => {
    const handleSearch = jest.fn();
    render(<SearchForm onSearch={handleSearch} />);

    await userEvent.type(screen.getByLabelText('Search products'), '  notebook  ');
    await userEvent.click(screen.getByRole('button', { name: 'Search' }));

    expect(handleSearch).toHaveBeenCalledWith('notebook');
  });

  it('shows a validation error when submitted with an empty query', async () => {
    render(<SearchForm onSearch={jest.fn()} />);

    await userEvent.click(screen.getByRole('button', { name: 'Search' }));

    expect(screen.getByRole('alert')).toHaveTextContent('Search query is required.');
  });
});
```

---

## Over-Engineering vs. Simplicity

### Overly complex (avoid for a simple toggle)

```tsx
// A context + reducer + hook for one boolean value in one component.
const ModalContext = createContext<{ isOpen: boolean; toggle: () => void } | null>(null);

function ModalProvider({ children }: { children: ReactNode }) {
  const [isOpen, dispatch] = useReducer((state: boolean, action: 'toggle') =>
    action === 'toggle' ? !state : state, false);
  return (
    <ModalContext.Provider value={{ isOpen, toggle: () => dispatch('toggle') }}>
      {children}
    </ModalContext.Provider>
  );
}
```

### Simplified (prefer for a local boolean)

```tsx
function ProductPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <>
      <button onClick={() => setIsModalOpen(true)}>View details</button>
      {isModalOpen && <ProductModal onClose={() => setIsModalOpen(false)} />}
    </>
  );
}
```

---

## Loading and Error States

```tsx
function ProductList() {
  const { products, isLoading, error } = useProducts('electronics');

  if (isLoading) {
    return <p role="status">Loading products…</p>;
  }

  if (error) {
    return <p role="alert">{error}</p>;
  }

  if (products.length === 0) {
    return <p>No products found.</p>;
  }

  return (
    <ul>
      {products.map((product) => (
        <li key={product.id}>
          <ProductCard {...product} onSelect={handleSelect} />
        </li>
      ))}
    </ul>
  );
}
```

---

## Error Boundary and Suspense

```tsx
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';

function ProductSection() {
  return (
    <ErrorBoundary
      fallback={<p role="alert">Failed to load products. Please refresh.</p>}
      onError={(error, info) => console.error('ProductSection error', error, info)}
    >
      <Suspense fallback={<p role="status">Loading products…</p>}>
        <ProductList />
      </Suspense>
    </ErrorBoundary>
  );
}
```

Wrap async boundaries (data-fetching components, lazy-loaded routes) with both `ErrorBoundary` and `Suspense`. Always provide an accessible fallback with a `role` attribute.

---

## React-Specific Anti-Patterns

### Stale Closure in useEffect

```tsx
// Anti-pattern: count is captured at render time and never updates.
useEffect(() => {
  const id = setInterval(() => {
    setCount(count + 1); // count is stale after the first interval
  }, 1000);
  return () => clearInterval(id);
}, []); // missing dependency

// Correct: use the functional updater form.
useEffect(() => {
  const id = setInterval(() => {
    setCount((prev) => prev + 1); // always uses the latest value
  }, 1000);
  return () => clearInterval(id);
}, []);
```

### useEffect for Derived State

```tsx
// Anti-pattern: synchronizes two pieces of state that should be one.
const [items, setItems] = useState<Item[]>([]);
const [total, setTotal] = useState(0);

useEffect(() => {
  setTotal(items.reduce((sum, item) => sum + item.price, 0));
}, [items]);

// Correct: derive during render — no useEffect needed.
const [items, setItems] = useState<Item[]>([]);
const total = items.reduce((sum, item) => sum + item.price, 0);
```

### Direct State Mutation

```tsx
// Anti-pattern: mutating the array in place — React won't detect the change.
function removeItem(index: number) {
  items.splice(index, 1); // mutation!
  setItems(items);
}

// Correct: return a new array.
function removeItem(index: number) {
  setItems((prev) => prev.filter((_, i) => i !== index));
}
```

### Index as Key in Dynamic List

```tsx
// Anti-pattern: reordering or removing items breaks reconciliation.
{items.map((item, index) => (
  <ProductCard key={index} {...item} />
))}

// Correct: use a stable, unique identifier.
{items.map((item) => (
  <ProductCard key={item.id} {...item} />
))}
```

### Global State for Local Data

```tsx
// Anti-pattern: a modal's open state in the global store.
// redux/uiSlice.ts
const uiSlice = createSlice({
  name: 'ui',
  initialState: { isProductModalOpen: false },
  reducers: { toggleModal: (state) => { state.isProductModalOpen = !state.isProductModalOpen; } }
});

// Correct: local state for data used by one component tree.
function ProductPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  return (
    <>
      <button onClick={() => setIsModalOpen(true)}>Open</button>
      {isModalOpen && <ProductModal onClose={() => setIsModalOpen(false)} />}
    </>
  );
}
```

---

## useEffect with Cleanup

```tsx
function useWindowWidth() {
  const [width, setWidth] = useState(window.innerWidth);

  useEffect(() => {
    function handleResize() {
      setWidth(window.innerWidth);
    }

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []); // empty deps: set up once, clean up on unmount

  return width;
}
```
