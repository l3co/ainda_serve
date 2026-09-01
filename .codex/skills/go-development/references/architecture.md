# Go Architecture Guidance

## Minimal Starting Point

Start every Go project with the simplest structure that makes the code work and the tests pass. A single `main.go` and a few `.go` files in a package is a valid starting point. Add layers only when real complexity demands it.

Before introducing a new layer, abstraction, or package, verify:

- Is there genuine complexity that this layer resolves?
- Will this abstraction be used in more than one place?
- Does it reduce coupling or merely add indirection?
- Is there a real current requirement — not a hypothetical future one?
- Would a simpler approach be insufficient?

If the answer to most of these is "no," keep it flat.

## Incremental Evolution

Design grows with the problem:

1. Understand the current requirement fully.
2. Identify the smallest useful increment.
3. Implement the behavior.
4. Validate through tests and review.
5. Refactor only when cohesion or clarity is genuinely suffering.
6. Document risks and natural evolution points.

Avoid designing for a future that may never arrive.

## Package Organization

### Small and medium projects

A flat structure with a few focused packages is idiomatic Go:

```
myservice/
├── go.mod
├── main.go
├── config/
│   └── config.go
├── handler/
│   └── user.go
├── store/
│   └── user.go
└── domain/
    └── user.go
```

### Larger projects

When a project grows to multiple bounded concerns, organize by domain or feature:

```
myservice/
├── go.mod
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── user/
│   │   ├── handler.go
│   │   ├── service.go
│   │   ├── repository.go
│   │   └── user.go
│   └── order/
│       ├── handler.go
│       ├── service.go
│       └── order.go
└── pkg/
    └── pagination/
        └── pagination.go
```

Use `internal/` to prevent external packages from importing implementation details. Use `pkg/` only for packages genuinely intended for external use.

## Separation of Responsibilities

In a Go service, a natural separation is:

- **Domain types**: plain Go structs and functions representing business rules. No framework dependencies.
- **Service / use-case layer**: orchestrates domain logic and calls repositories. Depends on interfaces, not concrete implementations.
- **Repository / adapter layer**: talks to databases, external APIs, or other I/O. Implements interfaces defined by the service layer.
- **Handler / delivery layer**: HTTP handlers, gRPC servers, CLI commands. Translates external requests to use-case calls and maps results to responses.

This is not a mandatory four-layer architecture for all projects. For a simple CRUD service, a handler calling a store directly may be entirely appropriate.

## Interfaces and Dependency Inversion

Define interfaces in the consuming package, not the providing package:

```go
// In the service package — define what you need:
type UserRepository interface {
    FindByID(ctx context.Context, id string) (User, error)
    Save(ctx context.Context, user User) error
}
```

This keeps the service testable without importing a concrete storage package.

Keep interfaces small. A single-method interface is idiomatic Go. Avoid defining a large interface that mirrors an entire struct — only include the methods the consumer actually uses.

## When to Apply Domain-Driven Design

DDD concepts are useful in Go when:

- The business domain has complex rules, invariants, or state transitions
- Multiple subdomains exist with distinct models and boundaries
- Long-lived aggregates with lifecycle management are needed
- A rich ubiquitous language is important to communicate with stakeholders
- The codebase is expected to grow and evolve over years

Do not apply DDD to:

- Simple CRUD services
- Internal tools
- Microservices with trivial domain logic
- Short-lived or prototype projects

When DDD is appropriate, consider: entities, value objects, aggregates, domain services, repositories, domain events, and bounded contexts. A bounded context maps naturally to a Go module or `internal/` subdirectory.

## When to Apply Clean Architecture

Clean Architecture (or Hexagonal Architecture) is appropriate when:

- The project must support multiple delivery mechanisms (HTTP, gRPC, CLI) sharing the same business logic
- The storage technology is expected to change or be replaced
- Testability of business logic in complete isolation is a hard requirement
- The team is large enough that clear dependency rules prevent coupling errors

For small teams or simple services, the cost of strict Clean Architecture layers exceeds the benefit. Prefer a pragmatic layered approach where dependencies flow inward without enforcing every Clean Architecture detail.

## Criteria for New Layers

Create a new package or layer when:

- It has a clear, single responsibility
- It is used by at least two distinct consumers, or its testability requires isolation
- The existing package would become incoherent without the split
- Naming the new package clearly is possible without resorting to "util" or "common"

Do not create packages just to satisfy a perceived architectural pattern.

## Criteria Against Premature Abstraction

Do not abstract:

- An interface with only one implementation and no plan for a second
- A factory that simply calls a constructor
- A repository type that wraps a single function call
- A service that does nothing but delegate to another
- Wrappers that add no behavior, error context, or testability benefit

The rule: if you cannot name two or more concrete reasons to introduce an abstraction today, do not introduce it.

## Modularization

Use Go modules (`go.mod`) for dependency management. For monorepos or large systems, consider multiple modules only when:

- Independent versioning is genuinely required
- Clear ownership boundaries between teams exist
- Build-time isolation provides measurable benefit

Multi-module setups add complexity. Default to a single module until there is a clear reason to split.

## Architectural Decision Proportionality

Match the architectural complexity to the real complexity of the problem:

| Project type | Appropriate structure |
|---|---|
| CLI tool | `main.go` + a few packages |
| Simple REST API | handler, service, store packages |
| Multi-domain service | `internal/` per domain, interfaces between layers |
| Complex domain | DDD aggregates, domain events, bounded contexts |
| Multi-delivery system | Clean Architecture or Hexagonal |

Starting at the bottom of this table when the problem belongs at the top is a costly mistake. Evolve upward as the project grows.
