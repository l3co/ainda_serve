# Python Architecture Guidance

## Minimal Starting Point

Start every Python project or feature with the simplest structure that makes the code work and the tests pass. A module with a few functions is a valid starting point. A class is valid when you need to encapsulate state with associated behavior. Add layers only when real complexity demands them.

Before introducing a new module, class, or abstraction layer, ask:

- Is there genuine complexity that this layer resolves?
- Will this abstraction be used by more than one consumer?
- Does it reduce coupling or merely add indirection?
- Is there a real current requirement — not a hypothetical future one?
- Would a simpler design be insufficient?

If most answers are "no," keep it flat.

## When to Use Functions vs. Classes

**Prefer functions when:**

- There is no state that needs to be maintained between calls
- The logic is a transformation: input → output
- The code is a collection of related pure operations
- No identity, lifecycle, or invariants are involved

**Prefer classes when:**

- State must be preserved and mutated coherently
- Multiple methods share and operate on the same data
- The object has identity (not just value equality)
- Invariants must be enforced across the object's lifetime
- A protocol or interface is being implemented

Do not create a class as a namespace for static methods — use a module instead.

## Module and Package Organization

For small projects, a single module or a few modules per concern:

```
myservice/
├── __init__.py
├── config.py
├── models.py
├── service.py
└── repository.py
```

For larger projects, organize by domain feature:

```
myservice/
├── __init__.py
├── orders/
│   ├── __init__.py
│   ├── models.py
│   ├── service.py
│   ├── repository.py
│   └── router.py        # FastAPI router or Django views
├── customers/
│   ├── __init__.py
│   ├── models.py
│   └── service.py
└── shared/
    ├── __init__.py
    └── pagination.py
```

Avoid `utils.py` or `helpers.py` at the root — name modules after what they provide.

## Separation of Responsibilities

In a Python service, a natural separation is:

- **Domain types**: Plain dataclasses, NamedTuples, or Pydantic models representing business concepts. No framework-specific decorators in the core model where possible.
- **Service / use-case functions or classes**: Orchestrate domain logic, call repositories, publish events. Accept collaborators as arguments — not imported singletons.
- **Repository functions or classes**: Abstract data access. Accept a database session or connection as an argument — not a module-level connection.
- **Delivery layer**: FastAPI routers, Django views, CLI commands. Translate requests to service calls, map results to responses.

This is a guide, not a mandate. For a simple CRUD endpoint, a view function calling a query function directly may be entirely appropriate.

## Dependency Injection

Python does not have a built-in DI container. Common patterns:

- **Constructor injection**: Pass collaborators as `__init__` parameters. Most explicit and testable.
- **Function parameters**: For stateless collaborators, pass them as function arguments.
- **Default arguments**: For optional collaborators with sensible defaults:
  ```python
  def send_notification(user_id: str, sender: NotificationSender = DefaultSender()) -> None:
      ...
  ```

Avoid module-level singletons for collaborators that vary between environments (databases, HTTP clients, caches). Instantiate them once at the application entry point and inject them.

When using FastAPI, use `Depends()` for dependency injection at the router level. When using Django, use the Django DI or service layer pattern.

## When to Apply Domain-Driven Design

Consider DDD in Python when:

- The domain has complex business rules, invariants, or state transitions
- Multiple bounded contexts exist with distinct models
- A rich ubiquitous language is important for team communication
- Aggregates are needed to enforce consistency
- Domain events decouple subsystems naturally

Do not apply DDD to:

- Simple CRUD APIs
- Data pipelines with no business rules
- Scripts or internal tools
- Projects where the complexity does not justify the ceremony

When DDD is appropriate, model with dataclasses or Pydantic models for value objects, dedicated service functions or classes for domain operations, and explicit repository interfaces (Protocols or ABCs).

## When to Apply Clean Architecture

Clean Architecture is appropriate when:

- Multiple delivery mechanisms share the same business logic (REST + CLI + async consumer)
- The framework may be replaced or tested in isolation
- The team needs enforceable dependency rules

For most Python web services, a pragmatic three-layer approach (router/view → service → repository) is sufficient and far easier to navigate.

## Asynchronous Design

When using `asyncio`:

- Use `async def` and `await` consistently — do not mix sync and async in the same call chain without explicit thread pool (`run_in_executor`)
- Use async libraries for all I/O within async contexts (async database drivers, `httpx`, `aiofiles`)
- Avoid blocking calls in async functions — they block the event loop
- Structure background tasks with proper lifecycle management (startup/shutdown hooks)

## Criteria Against Premature Abstraction

Do not create:

- Abstract base classes with a single concrete subclass
- Protocols with no second implementation in sight
- Service classes that only forward calls to a repository
- Factory functions for objects that have simple constructors
- Decorators that add no observable behavior

## Architectural Decision Proportionality

| Project type | Appropriate structure |
|---|---|
| Script or CLI tool | One or a few modules, functions |
| Simple REST API | Router, service function, repository function |
| Multi-feature service | Package-by-feature, service + repository per domain |
| Complex domain | DDD-inspired modules with explicit domain types |
| Multi-delivery system | Clean Architecture ports and adapters |

Start at the appropriate level and evolve upward when the problem genuinely demands it.
