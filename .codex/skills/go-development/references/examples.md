# Go Idiomatic Examples

Short, focused examples. Not a complete application — reference patterns only.

---

## Package Organization

```
order/
├── order.go         # domain types and business rules
├── repository.go    # interface defined here, consumed here
├── service.go       # use-case logic
├── service_test.go  # behavior tests using fake repository
└── handler.go       # HTTP delivery (depends on service interface)
```

---

## Cohesive Function

```go
// Calculates the total price of an order including tax.
// Returns an error if any item has a zero or negative price.
func calculateTotal(items []Item, taxRate float64) (int64, error) {
    var total int64
    for _, item := range items {
        if item.PriceInCents <= 0 {
            return 0, fmt.Errorf("calculateTotal: item %q has invalid price %d", item.Name, item.PriceInCents)
        }
        total += item.PriceInCents * int64(item.Quantity)
    }
    tax := int64(float64(total) * taxRate)
    return total + tax, nil
}
```

---

## Error Handling

```go
// Idiomatic: wrap with context, return the error to the caller.
func (s *UserService) Create(ctx context.Context, cmd CreateUserCommand) (User, error) {
    if cmd.Email == "" {
        return User{}, fmt.Errorf("create user: email is required")
    }

    hashed, err := s.hasher.Hash(cmd.Password)
    if err != nil {
        return User{}, fmt.Errorf("create user: hash password: %w", err)
    }

    user := User{
        ID:           newID(),
        Email:        cmd.Email,
        PasswordHash: hashed,
    }

    if err := s.repo.Save(ctx, user); err != nil {
        return User{}, fmt.Errorf("create user: save: %w", err)
    }

    return user, nil
}
```

---

## Interface Near Consumer

```go
// In the service package — only the methods we need:
type UserStore interface {
    FindByEmail(ctx context.Context, email string) (User, error)
    Save(ctx context.Context, user User) error
}

type UserService struct {
    store  UserStore
    hasher PasswordHasher
}
```

---

## Table-Driven Test

```go
func TestCalculateTotal(t *testing.T) {
    tests := []struct {
        name    string
        items   []Item
        taxRate float64
        want    int64
        wantErr bool
    }{
        {
            name:    "single item no tax",
            items:   []Item{{Name: "book", PriceInCents: 1000, Quantity: 1}},
            taxRate: 0.0,
            want:    1000,
        },
        {
            name:    "multiple items with tax",
            items:   []Item{
                {Name: "book", PriceInCents: 1000, Quantity: 2},
                {Name: "pen", PriceInCents: 200, Quantity: 3},
            },
            taxRate: 0.10,
            want:    2860, // (2000 + 600) * 1.10
        },
        {
            name:    "zero price returns error",
            items:   []Item{{Name: "free", PriceInCents: 0, Quantity: 1}},
            wantErr: true,
        },
    }

    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            got, err := calculateTotal(tc.items, tc.taxRate)
            if (err != nil) != tc.wantErr {
                t.Fatalf("error = %v, wantErr = %v", err, tc.wantErr)
            }
            if !tc.wantErr && got != tc.want {
                t.Errorf("got %d, want %d", got, tc.want)
            }
        })
    }
}
```

---

## Appropriate Abstraction: Fake Repository

```go
// In the test file — a hand-written in-memory fake.
type fakeUserStore struct {
    users map[string]User
}

func newFakeUserStore() *fakeUserStore {
    return &fakeUserStore{users: make(map[string]User)}
}

func (f *fakeUserStore) Save(_ context.Context, u User) error {
    f.users[u.ID] = u
    return nil
}

func (f *fakeUserStore) FindByEmail(_ context.Context, email string) (User, error) {
    for _, u := range f.users {
        if u.Email == email {
            return u, nil
        }
    }
    return User{}, ErrNotFound
}
```

---

## Over-Engineering vs. Simplicity

### Overly complex (avoid)

```go
// Factory for a repository that has only one implementation.
type UserRepositoryFactory interface {
    CreateUserRepository(cfg RepositoryConfig) (UserRepository, error)
}

type DefaultUserRepositoryFactory struct{}

func (f *DefaultUserRepositoryFactory) CreateUserRepository(cfg RepositoryConfig) (UserRepository, error) {
    return NewPostgresUserRepository(cfg.DSN)
}
```

### Simplified (prefer)

```go
// A constructor is sufficient. No factory needed.
func NewUserRepository(db *sql.DB) *UserRepository {
    return &UserRepository{db: db}
}
```

---

## Goroutine with Context Cancellation

```go
func processItems(ctx context.Context, items <-chan Item, results chan<- Result) {
    for {
        select {
        case <-ctx.Done():
            return
        case item, ok := <-items:
            if !ok {
                return
            }
            result := process(item)
            select {
            case results <- result:
            case <-ctx.Done():
                return
            }
        }
    }
}
```

---

## Context Usage

```go
// Correct: context as first parameter.
func (r *UserRepository) FindByID(ctx context.Context, id string) (User, error) {
    row := r.db.QueryRowContext(ctx, "SELECT id, email FROM users WHERE id = $1", id)
    var u User
    if err := row.Scan(&u.ID, &u.Email); err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return User{}, ErrNotFound
        }
        return User{}, fmt.Errorf("find user by id: %w", err)
    }
    return u, nil
}
```

---

## Go-Specific Anti-Patterns

### Goroutine Leak

```go
// Anti-pattern: goroutine with no termination path.
func startWorker(jobs <-chan Job) {
    go func() {
        for job := range jobs {
            process(job)
        }
        // If `jobs` is never closed, this goroutine leaks forever.
    }()
}

// Correct: context cancellation provides a termination path.
func startWorker(ctx context.Context, jobs <-chan Job) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return
            case job, ok := <-jobs:
                if !ok {
                    return
                }
                process(job)
            }
        }
    }()
}
```

### Swallowed Error

```go
// Anti-pattern: error discarded silently.
result, _ := fetchUser(ctx, id)

// Correct: handle or propagate.
result, err := fetchUser(ctx, id)
if err != nil {
    return fmt.Errorf("load user %s: %w", id, err)
}
```

### Interface in Providing Package

```go
// Anti-pattern: interface defined where it is implemented.
// package store
type UserRepository interface { Save(User) error }
type PostgresUserRepository struct{}
func (r *PostgresUserRepository) Save(u User) error { ... }

// Correct: interface defined where it is consumed.
// package service
type UserStore interface { Save(User) error }
```

### Panic Instead of Error

```go
// Anti-pattern: panic for an expected runtime condition.
func mustFindUser(id string) User {
    u, err := repo.Find(id)
    if err != nil {
        panic(err) // callers cannot recover gracefully
    }
    return u
}

// Correct: return an error.
func findUser(id string) (User, error) {
    return repo.Find(id)
}
```
