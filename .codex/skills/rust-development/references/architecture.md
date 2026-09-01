# Rust Architecture Guidance

## Minimal Starting Point

Start every Rust project or feature with the simplest structure that compiles, passes tests, and solves the actual problem. A single module or a flat crate is a valid starting point. Add modules, crates, or layers only when real complexity demands them.

Before creating a new module, trait, or crate boundary, ask:

- Is there genuine complexity that this separation resolves?
- Will this trait or abstraction have two or more implementations?
- Does this module boundary reduce cognitive load or enforce a meaningful encapsulation?
- Is there a real current requirement — not a hypothetical future one?
- Would a simpler design be insufficient?

## Crate and Module Organization

### Single crate (start here)

```
my-service/
├── Cargo.toml
├── src/
│   ├── main.rs        or lib.rs
│   ├── config.rs
│   ├── domain/
│   │   ├── mod.rs
│   │   ├── order.rs
│   │   └── user.rs
│   ├── repository/
│   │   ├── mod.rs
│   │   └── postgres.rs
│   └── handler/
│       ├── mod.rs
│       └── order.rs
└── tests/
    └── order_flow.rs
```

### Workspace (when genuine separation is needed)

```
my-workspace/
├── Cargo.toml         (workspace manifest)
├── crates/
│   ├── domain/        (business logic, no I/O)
│   │   └── Cargo.toml
│   ├── infra/         (database, HTTP client)
│   │   └── Cargo.toml
│   └── api/           (HTTP server binary)
│       └── Cargo.toml
```

Use a workspace when:

- Independent versioning of components is required
- Build-time isolation between teams provides measurable benefit
- A library crate needs to be published separately

Default to a single crate and single workspace until there is a clear reason to split.

## Separation of Responsibilities

In a Rust service, a natural separation is:

- **Domain types and functions**: plain Rust structs, enums, and functions. No I/O. No async unless the domain operation is inherently async. Models invariants using types.
- **Service / use-case functions**: orchestrate domain logic, call repositories. Depend on traits, not concrete implementations.
- **Repository / adapter layer**: implements traits using database drivers, HTTP clients, or filesystem access.
- **Delivery layer**: HTTP handlers (Axum, Actix, Warp), CLI argument parsing (Clap), gRPC. Translates input to service calls.

Keep the domain layer free of framework-specific imports. It should be testable with no database and no network.

## Traits and Dependency Inversion

Define traits where they are consumed:

```rust
// In the service module — only what the service needs:
pub trait OrderRepository {
    async fn find_by_id(&self, id: &OrderId) -> Result<Option<Order>, RepositoryError>;
    async fn save(&self, order: &Order) -> Result<(), RepositoryError>;
}
```

The concrete implementation (`PostgresOrderRepository`) lives in the infrastructure layer and implements this trait.

Keep traits narrow. A two-method trait is often right. A ten-method trait is a sign that the abstraction is too broad.

Do not define a trait unless:

- Two or more implementations exist now, or
- Testability requires substituting the implementation in tests

A struct with inherent methods is simpler when there is only one implementation.

## Error Types

Design error types to communicate accurately:

- Use `thiserror` for library and service errors (derive `std::error::Error` cleanly)
- Use `anyhow` for application-level error propagation when precise error types are not needed by callers
- Do not mix `thiserror` and `anyhow` at the same layer — choose one style per layer

```rust
#[derive(Debug, thiserror::Error)]
pub enum OrderError {
    #[error("order not found: {0}")]
    NotFound(OrderId),
    #[error("order cannot be cancelled in state {0:?}")]
    InvalidTransition(OrderStatus),
    #[error("repository error: {0}")]
    Repository(#[from] RepositoryError),
}
```

## Ownership and Data Flow

Design data ownership explicitly:

- If a function only needs to read data, accept a reference: `&Order`
- If a function needs to own data for the duration of its lifetime, accept it by value: `Order`
- If a function stores the data and outlives the caller, it must own it: field of type `Order`, not `&Order`

Work with the borrow checker by clarifying ownership intent in the types. The most common borrow checker problems are symptoms of unclear ownership, not language limitations.

## Async Design

When using `async`/`await`:

- Choose one async runtime per binary (Tokio is the most common for services)
- Use `async` at the boundary with I/O — not everywhere
- Domain logic and pure calculations should be synchronous functions
- Use `tokio::spawn` for background tasks with explicit lifecycle management
- Use `tokio::select!` for concurrent operations with cancellation
- Avoid holding non-`Send` types across `await` points

## When to Apply Domain-Driven Design

Consider DDD concepts in Rust when:

- The domain has complex invariants that should be encoded in types
- Multiple aggregates exist with distinct lifecycle and consistency boundaries
- Domain events are a natural fit for decoupling subsystems
- The codebase is long-lived and the domain model is central to correctness

The Rust type system is naturally well-suited to encoding domain invariants. A `Money` type that enforces non-negativity, a `UserId(Uuid)` newtype, or a `sealed enum` for a finite state machine are idiomatic Rust and align with DDD value objects and domain modeling.

Do not apply DDD to:

- Small utilities or CLI tools
- Services whose "domain" is a thin CRUD layer over a database

## Criteria Against Premature Abstraction

Do not create:

- A trait with one implementation and no test double in sight
- A generic function with one concrete type instantiation
- A module boundary that splits two things that always change together
- A crate separation for code that does not need independent versioning

## Architectural Decision Proportionality

| Project type | Appropriate structure |
|---|---|
| CLI tool | `main.rs` + a few modules |
| Simple REST API | handler, service, repository modules in one crate |
| Multi-domain service | Sub-modules per domain with trait-based boundaries |
| Complex domain | DDD-inspired types and domain events, workspace |
| Multi-binary | Workspace with shared library crates |
