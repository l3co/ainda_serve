# Java-Specific Guardrails

These guardrails apply to all agents working on Java codebases. They extend — not replace — the shared guardrails in `../shared/guardrails.md`. In any conflict, the shared guardrails take precedence unless noted here.

---

## Exception Handling

MUST NOT swallow exceptions with an empty catch block.

MUST NOT catch `Throwable`, `Error`, or `RuntimeException` broadly without a documented reason.

MUST NOT use checked exceptions for programming errors — use unchecked exceptions.

MUST NOT use exceptions for normal control flow.

MUST always include the original exception as the cause when wrapping: `throw new AppException("context", e)`.

MUST NOT catch and re-throw the same exception without adding context.

SHOULD define domain-specific exceptions at the appropriate layer (e.g., `OrderNotFoundException` in the domain, not in the persistence layer).

---

## Dependency Injection and Design

MUST use constructor injection — not field injection (`@Autowired` on fields).

MUST NOT use `@Autowired` field injection. Declare dependencies as constructor parameters.

MUST NOT use `ApplicationContext` directly to look up beans at runtime unless unavoidable.

MUST NOT use `static` methods for logic that has dependencies or side effects.

MUST NOT create services that only delegate to other services without adding orchestration, validation, or cross-cutting behavior.

MUST NOT create interfaces with a single implementation without a clear testability or abstraction boundary reason.

SHOULD inject interfaces, not concrete types.

---

## Records and Sealed Classes

SHOULD use records for immutable value objects.

SHOULD use sealed classes/interfaces for algebraic types (closed sets of variants).

MUST NOT create mutable records.

MUST NOT use records for entities that have identity beyond their fields (prefer classes with explicit `equals`/`hashCode`).

SHOULD use pattern matching (`instanceof` patterns, switch expressions) with sealed types to handle all cases exhaustively.

---

## Null Safety

MUST NOT return `null` from methods that may legitimately return an absent value — use `Optional<T>`.

MUST NOT use `Optional` as a method parameter.

MUST NOT store `Optional` in fields.

SHOULD use `@NonNull` / `@Nullable` annotations at API boundaries for tooling support.

MUST validate constructor parameters with `Objects.requireNonNull` for mandatory dependencies.

---

## Streams and Functional Patterns

MUST NOT create streams from side-effecting sources in ways that are order-dependent.

MUST NOT use `.peek()` for production debugging — use it only in test contexts.

SHOULD break long stream pipelines into named intermediate steps when readability suffers.

MUST NOT use `.get()` on an `Optional` without first checking `.isPresent()` — prefer `.orElseThrow()` or `.map()`.

MUST NOT use parallel streams without profiling evidence of a bottleneck.

---

## Spring-Specific (when Spring is present)

MUST use `@Transactional` at the service layer, not the repository layer, for multi-step domain operations.

MUST NOT use `@Transactional(readOnly = false)` as a default — be explicit about read/write semantics.

MUST NOT open transactions during object construction.

MUST NOT hold transactions open while waiting for external calls.

SHOULD use `@DataJpaTest` for persistence-layer tests and `@WebMvcTest` for web-layer tests.

MUST NOT use `@SpringBootTest` for tests that do not require the full application context.

SHOULD configure property sources for tests using `@TestPropertySource` or `application-test.properties`.

---

## Testing

MUST use JUnit 5 (`@Test`, `@ParameterizedTest`, `@ExtendWith`) — not JUnit 4 annotations.

MUST prefer AssertJ for assertions — not raw `assertEquals` from JUnit.

MUST NOT depend on test execution order.

MUST NOT use `Thread.sleep` in tests — use `Awaitility` or controlled mocks for async.

MUST NOT use `@SpringBootTest` when a slice test (`@WebMvcTest`, `@DataJpaTest`) would suffice.

SHOULD test error paths, exception boundaries, and validation failures — not only happy paths.

MUST NOT write tests that only test framework plumbing.

---

## Security (Java-Specific)

MUST use parameterized queries or JPA's named parameters — never concatenate user input into JPQL or SQL.

MUST NOT use `ObjectInputStream` to deserialize untrusted data.

MUST validate and sanitize all user input at the controller or service boundary.

MUST NOT expose stack traces to HTTP response bodies.

MUST use `BCryptPasswordEncoder` or equivalent — never `MD5`, `SHA-1`, or plain text for passwords.

MUST NOT use `System.getProperty` to access credentials — use externalized configuration.

MUST NOT log request parameters or bodies that may contain credentials or PII.

SHOULD use Spring Security's `@PreAuthorize` or equivalent for method-level authorization.

---

## Observability

SHOULD use SLF4J with a structured backend (Logback, Log4j2).

MUST NOT use `System.out.println` for operational logging.

SHOULD propagate MDC context across async boundaries (thread pools, `CompletableFuture`).

MUST include `request_id` or equivalent trace context in all log entries for distributed flows.

MUST NOT log sensitive data (passwords, tokens, personal identifiers).

SHOULD use `logger.info("event occurred: orderId={}", orderId)` — parameterized, not string-concatenated.

---

## Code Style Guardrails

MUST use `var` (local type inference) only where the inferred type is obvious from the right-hand side.

MUST NOT suppress warnings with `@SuppressWarnings` without a comment explaining the reason.

MUST NOT use raw types — always provide type parameters.

MUST NOT rely on implicit `toString()` in production output — always use explicit formatting.

MUST prefer `List.of()`, `Map.of()`, `Set.of()` for immutable collections over `Collections.unmodifiableList`.
