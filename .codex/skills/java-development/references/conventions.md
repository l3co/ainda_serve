# Java Conventions

## Naming

- **Classes**: `PascalCase` — `OrderService`, `UserRepository`, `PaymentGateway`
- **Interfaces**: `PascalCase`, often a noun or adjective — `Printable`, `UserRepository`, `NotificationSender`
- **Methods**: `camelCase` — `calculateTotal`, `findByEmail`, `sendNotification`
- **Variables and fields**: `camelCase` — `orderTotal`, `userId`, `paymentGateway`
- **Constants**: `UPPER_SNAKE_CASE` — `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS`
- **Packages**: lowercase, singular — `com.example.order`, `com.example.user`
- All identifiers must be in English.
- Avoid generic names: `Manager`, `Helper`, `Util`, `Processor`, `Handler` — use them only when they genuinely describe the responsibility.
- Test classes: `<ClassUnderTest>Test.java` — `OrderServiceTest.java`

## File Organization

- One top-level class per file; the filename matches the class name.
- Group related classes in the same package, not by technical role.
- Keep static utility classes minimal; prefer instance methods with dependency injection.
- Place test classes in `src/test/java` mirroring the package structure of the class under test.

## Package Structure

- Organize by domain: `com.example.order`, `com.example.user`, `com.example.payment`
- Avoid: `com.example.service`, `com.example.controller`, `com.example.repository` as top-level groupings (layer-by-layer packaging)
- Use `internal` sub-packages for implementation details not intended for external consumption

## Visibility

- Default to the most restrictive visibility possible.
- Prefer package-private for classes not intended for external use.
- Expose only what is required at each boundary.
- Do not make fields `public` — use constructors, records, or factory methods.

## Immutability

- Prefer immutable objects for value types and data transfer objects.
- Use `record` for immutable data carriers (Java 16+).
- Make fields `final` when they are not meant to change after construction.
- Use `Collections.unmodifiableList` or `List.copyOf` when exposing collections.
- Do not expose mutable collection fields directly.

## Exception Handling

- Use checked exceptions for recoverable, expected failures (e.g., `IOException`, domain-specific `OrderNotFoundException`).
- Use unchecked exceptions for programming errors and unrecoverable failures.
- Do not catch `Exception` or `Throwable` unless at a boundary (e.g., a global exception handler).
- Never swallow exceptions with an empty catch block. If you must ignore an exception, document why.
- Provide meaningful, actionable messages — not "An error occurred."
- Do not log and re-throw the same exception at the same level — choose one or the other.
- Exception messages must be in English.
- Extend `RuntimeException` for domain exceptions when using unchecked exceptions in an application service.

## Optional

- Use `Optional<T>` as a method return type when a value may legitimately be absent.
- Do not use `Optional` as a field type, constructor parameter, or method parameter.
- Do not call `.get()` without checking `isPresent()` first — prefer `orElse`, `orElseGet`, `orElseThrow`, `map`, or `ifPresent`.
- Use `Optional.ofNullable` when wrapping external values that may be null.

## Collections and Streams

- Prefer immutable collection factories: `List.of(...)`, `Map.of(...)`, `Set.of(...)`.
- Use streams for transformations and aggregations — not for imperative loops with side effects.
- Avoid complex, nested streams that are hard to read. Extract intermediate steps into named variables or methods.
- Prefer `Collectors.toUnmodifiableList()` or `Stream.toList()` (Java 16+) when collecting to a list.

## Dependency Management

- Use Maven or Gradle as established by the project. Do not switch build tools without discussion.
- Declare the minimum Java version required using the build tool's toolchain or compatibility settings.
- Before adding a dependency: is it maintained? Is the license compatible? Does a standard library alternative exist? Is the project already importing an equivalent?
- Avoid adding a library for a single utility method that can be written in a few lines.

## Dependency Injection

- Use constructor injection — not field injection (`@Autowired` on fields) — for mandatory dependencies.
- Field injection hides dependencies and makes testing harder.
- Use setter injection only for optional dependencies.
- Do not instantiate dependencies inside a class — inject them from the outside.

## Concurrency

- Use `java.util.concurrent` types (`ExecutorService`, `CompletableFuture`, `BlockingQueue`) rather than raw threads.
- Prefer virtual threads (Java 21+) for I/O-bound concurrent tasks when the platform supports them and the benefit is demonstrated.
- Protect mutable shared state with `synchronized`, `ReentrantLock`, or `AtomicReference`.
- Prefer immutable shared state over synchronization where possible.
- Use `volatile` for a single flag — not for compound operations.

## Modern Java Features

- **Records**: use for immutable data (DTOs, value objects, command/query objects)
- **Sealed classes**: model closed hierarchies (state machines, result types, error types)
- **Pattern matching for instanceof**: eliminate explicit casts
- **Text blocks**: multi-line strings for SQL, JSON templates, messages
- **`var`**: use for local variables when the type is evident; avoid when it obscures the type

## Observability

### Structured Logging

Use SLF4J with Logback or Log4j2 and structured output:

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

@Service
public class OrderService {
    private static final Logger log = LoggerFactory.getLogger(OrderService.class);

    public Order createOrder(CreateOrderCommand command) {
        // MDC (Mapped Diagnostic Context) adds context to all log statements in scope:
        try (var ignored = MDC.putCloseable("orderId", command.orderId())) {
            log.info("creating order for customer {}", command.customerId());

            var order = /* ... */;

            log.info("order created successfully, total={}", order.totalInCents());
            return order;
        } catch (Exception e) {
            log.error("failed to create order for customer {}", command.customerId(), e);
            throw e;
        }
    }
}
```

With Lombok: use `@Slf4j` to avoid the static field declaration.

Rules:
- Use MDC to add request-scoped context (request ID, user ID, correlation ID) to all log entries.
- Log at the correct level: `DEBUG` for internal state, `INFO` for significant events, `WARN` for recoverable issues, `ERROR` for failures.
- Never log passwords, tokens, or PII — even at `DEBUG` level.
- Do not log and rethrow the same exception at the same level without adding context.
- Use parameterized logging (`log.info("value {}", val)`) — never string concatenation.

### Metrics

With Spring Boot Actuator + Micrometer:

```java
@Service
public class OrderService {
    private final Counter orderCreatedCounter;
    private final Timer orderCreationTimer;

    public OrderService(MeterRegistry registry) {
        this.orderCreatedCounter = registry.counter("orders.created");
        this.orderCreationTimer = registry.timer("orders.creation.duration");
    }

    public Order createOrder(CreateOrderCommand command) {
        return orderCreationTimer.record(() -> {
            var order = /* business logic */;
            orderCreatedCounter.increment();
            return order;
        });
    }
}
```

Instrument HTTP handlers, database operations, and external calls — not pure domain logic.

## Patterns to Avoid

- Mutable static state for application behavior
- Deep inheritance hierarchies
- Abstract base classes with a single concrete subclass
- Service classes that only delegate with no added logic
- `Manager`, `Helper`, `Util` class names with mixed responsibilities
- Catching `Exception` at a low level and wrapping in `RuntimeException`
- Using `Optional` as a parameter or field type
- Returning `null` from methods — use `Optional` or throw a meaningful exception
- `System.out.println` in production code — use a logging framework
- Magic numbers — define named constants
