# Java Architecture Guidance

## Minimal Starting Point

Begin every Java project or feature with the simplest structure that makes the code work and the tests pass. A single service class with a repository and a plain POJO is a valid starting point. Add layers only when real complexity demands them.

Before introducing a new layer, interface, or abstraction, ask:

- Is there genuine complexity that this layer resolves?
- Will this abstraction be used in more than one context?
- Does it reduce coupling or merely add indirection?
- Is there a real current requirement — not a hypothetical future one?
- Would a simpler design be insufficient?

If most answers are "no," stay flat.

## Package Organization

Organize by domain concern, not by technical role:

```
com.example.order/
├── Order.java               // domain type
├── OrderStatus.java         // enum or sealed class
├── OrderService.java        // use-case logic
├── OrderRepository.java     // interface
├── OrderController.java     // HTTP delivery (Spring, Jakarta, etc.)
└── OrderMapper.java         // DTO mapping if needed
```

Avoid organizing by layer (all controllers in one package, all services in another) for large projects — it creates artificial coupling between unrelated concerns.

Use `internal` sub-packages or module-info to restrict visibility when needed.

## Separation of Responsibilities

In a Java service, a natural separation is:

- **Domain model**: Plain Java objects, records, or value objects representing business concepts. No framework annotations in the core model unless absolutely necessary.
- **Application services**: Orchestrate domain objects, coordinate repository calls, publish events. No HTTP or persistence concerns.
- **Repository interfaces**: Define data access contracts in the domain/application layer. Implementations are in the infrastructure layer.
- **Infrastructure adapters**: JPA repositories, REST clients, message queue producers — implement domain interfaces.
- **Delivery layer**: Controllers, CLI entrypoints, event consumers. Translate external requests to application service calls.

This is a guide, not a mandate. For a simple CRUD feature, a controller calling a service calling a JPA repository directly may be entirely appropriate.

## SOLID Principles — Pragmatic Application

**Single Responsibility**: A class should have one primary reason to change. Do not split a class just because it is large — split it when it has multiple distinct responsibilities that change for different reasons.

**Open/Closed**: Favor extension points (interfaces, abstract methods) for things that are likely to vary. Do not add extension points for things that have never varied and may never vary.

**Liskov Substitution**: Subtypes must honor the contract of their supertypes. Avoid overriding methods in ways that weaken preconditions or strengthen postconditions.

**Interface Segregation**: Keep interfaces focused on what the consumer needs. A `UserRepository` that only searches by email does not need to expose delete or count methods.

**Dependency Inversion**: Application services depend on repository interfaces, not on JPA `EntityManager` or `JdbcTemplate` directly. Infrastructure implements the interface; the application defines it.

Apply SOLID as a diagnostic tool ("why does this class feel wrong?"), not a checklist.

## When to Apply Domain-Driven Design

Consider DDD in Java when:

- The domain has complex business rules, invariants, or lifecycle management
- Multiple bounded contexts exist that need explicit separation
- A rich ubiquitous language is important for team communication
- Aggregates are needed to enforce consistency boundaries
- Domain events are a natural fit for decoupling subsystems

Do not apply DDD to:

- Simple CRUD services with no meaningful business rules
- Internal tools or scripts
- Microservices where the "domain" is just a table with four columns
- Projects where the team has not been exposed to DDD concepts

When DDD is appropriate in Java, model with:

- **Entities**: identity-based objects with lifecycle (annotated with `@Entity` only in the persistence adapter, not in the domain)
- **Value objects**: immutable, equality by value (`record` is ideal in Java 16+)
- **Aggregates**: a cluster of entities with a root that enforces invariants
- **Domain services**: stateless operations that don't belong to a single entity
- **Repositories**: defined in the domain, implemented in infrastructure

## When to Apply Clean Architecture

Clean / Hexagonal Architecture is appropriate when:

- Multiple delivery mechanisms share the same business logic (REST API + CLI + async consumer)
- The storage technology may change (JPA today, NoSQL tomorrow)
- Testing business logic in complete isolation from Spring or Hibernate is a hard requirement
- The project will be maintained by a large team that needs enforceable dependency rules

For small projects or teams, Clean Architecture's ceremony may exceed its benefit. Use a pragmatic three-layer approach (controller → service → repository) and add boundaries as the project grows.

## Criteria for New Abstractions

Create a new interface, abstract class, or layer when:

- Two or more concrete implementations exist, or one is clearly imminent
- The collaborator needs to be replaced in tests without starting a database
- The class would otherwise violate the open/closed principle with a growing `if-else` chain
- The abstraction maps to a meaningful concept in the domain or in the team's language

Do not create interfaces just to have them. A `UserServiceImpl` that implements `UserService` with no second implementation is noise.

## Modern Java Design

Leverage modern Java features to simplify design:

- **Records** (Java 16+): immutable data carriers, ideal for value objects, DTOs, and command/query objects
- **Sealed classes** (Java 17+): exhaustive type hierarchies, useful for modeling domain states, results, or error types
- **Pattern matching** (Java 21+): replaces verbose `instanceof` checks and casts
- **Text blocks**: readable multi-line strings for SQL, JSON templates, or log messages
- **`var`**: use for local variables when the type is obvious from context; avoid when it hides an important type

## Criteria Against Premature Abstraction

Do not create:

- Service classes that only delegate to other services
- Repository interfaces with no second implementation in sight and no testability benefit
- Factory classes for objects that have simple constructors
- Mapper classes for trivial single-field DTOs
- Abstract base classes for one concrete subclass

## Architectural Decision Proportionality

| Project type | Appropriate structure |
|---|---|
| Utility / CLI tool | A few classes, no framework |
| Simple REST API | Controller, Service, Repository (JPA) |
| Multi-feature service | Package-by-feature with service/repository per domain |
| Complex domain | DDD aggregates, domain events, bounded contexts |
| Multi-delivery system | Hexagonal / Clean Architecture |

Start at the appropriate level and evolve upward only when the problem genuinely demands it.
