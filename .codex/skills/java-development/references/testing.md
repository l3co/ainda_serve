# Java Testing Strategy

## Philosophy

Tests validate observable behavior — what a component does from the outside — not how it does it internally. A test that breaks when you rename a private field is testing the wrong thing. A test that breaks when the contract changes is doing its job.

## Framework Baseline

- **JUnit 5** (`junit-jupiter`) for all new tests unless the project already uses JUnit 4.
- **Mockito** for test doubles when the project already uses it, or when mock frameworks are genuinely needed.
- **AssertJ** for readable, fluent assertions — if already in the project.
- **Spring Boot Test** utilities when testing Spring components in context.

Do not introduce new testing frameworks without justification.

## Test Organization

```
src/
├── main/java/com/example/order/
│   └── OrderService.java
└── test/java/com/example/order/
    ├── OrderServiceTest.java       // unit test
    └── OrderRepositoryIT.java     // integration test (suffix: IT or Integration)
```

Integration tests may use a different Maven/Gradle profile or failsafe plugin to run separately from unit tests.

## Unit Tests

Unit tests verify a single class or function in isolation:

```java
class OrderServiceTest {

    private final OrderRepository repository = mock(OrderRepository.class);
    private final OrderService service = new OrderService(repository);

    @Test
    void createsOrderWithCalculatedTotal() {
        var items = List.of(
            new OrderItem("book", 1000, 2),
            new OrderItem("pen", 200, 3)
        );
        when(repository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        var order = service.createOrder(items);

        assertThat(order.totalInCents()).isEqualTo(2600);
        verify(repository).save(order);
    }

    @Test
    void throwsExceptionWhenItemListIsEmpty() {
        assertThatThrownBy(() -> service.createOrder(List.of()))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("items");
    }
}
```

## Integration Tests

Integration tests verify real collaborations — typically the persistence layer:

```java
@SpringBootTest
@Transactional
class OrderRepositoryIT {

    @Autowired
    private OrderRepository repository;

    @Test
    void findsOrderByCustomerId() {
        var saved = repository.save(new Order("customer-1", List.of()));

        var found = repository.findByCustomerId("customer-1");

        assertThat(found).hasSize(1);
        assertThat(found.get(0).id()).isEqualTo(saved.id());
    }
}
```

Use `@Transactional` in integration tests to roll back changes after each test. Use `Testcontainers` for database integration tests when the project supports it.

## Contract Tests

Consider contract tests when:

- Multiple services communicate over HTTP or messaging
- An API is consumed by external teams
- You need to detect breaking changes before deployment

Use tools compatible with the project's CI pipeline. If no contract testing is established, note it as a gap and propose it as a future step.

## Test Doubles

| Double type | When to use |
|---|---|
| Mock (Mockito) | Verify interactions and stub return values for collaborators with complex behavior |
| Stub | Return fixed values from a collaborator without verifying calls |
| Fake | An in-memory implementation (e.g., `FakeOrderRepository`) — preferred for repositories |
| Spy | Wrap a real object to verify specific method calls |

Prefer fakes (in-memory implementations) for repositories and simple collaborators. Mocks are appropriate when verifying that a collaborator was called with specific arguments is part of the contract.

Avoid over-mocking: if a mock setup is longer than the assertion, the test is probably testing too much at once or using the wrong double type.

## Naming

Test methods must be in English and express:

- **What** is being tested
- **Under what condition**
- **What the expected outcome is**

```java
@Test
void createsOrderWithCalculatedTotal() { ... }

@Test
void throwsExceptionWhenItemListIsEmpty() { ... }

@Test
void returnsEmptyWhenNoOrdersFoundForCustomer() { ... }
```

Use `@DisplayName` for additional human-readable descriptions when the method name alone is not expressive enough:

```java
@Test
@DisplayName("should apply 10% discount when customer has premium status")
void appliesDiscountForPremiumCustomer() { ... }
```

## Parameterized Tests

Use `@ParameterizedTest` with `@MethodSource` or `@CsvSource` for data-driven cases:

```java
@ParameterizedTest
@CsvSource({
    "100, 0.10, 110",
    "200, 0.20, 240",
    "0,   0.10, 0"
})
void calculatesOrderTotalWithTax(int subtotal, double taxRate, int expectedTotal) {
    assertThat(calculateTotal(subtotal, taxRate)).isEqualTo(expectedTotal);
}
```

## Isolation

- Each test must be independent. Never rely on execution order.
- Reset mocks between tests (Mockito resets by default in `@ExtendWith(MockitoExtension.class)`).
- Do not share mutable test fixtures between test methods.
- Use `@BeforeEach` for per-test setup.
- Use `@BeforeAll` only for expensive setups that are truly read-only (e.g., starting a container).

## What to Test

Prioritize:

- Business rules and domain invariants
- Exception paths and error responses
- Boundary conditions (empty inputs, maximum values, null handling)
- Critical data flows (persistence, external calls)
- Regressions — every bug fix should add a test

Do not test:

- Java language behavior (`List.of()` returning an immutable list)
- Framework behavior already tested by the framework's own suite
- Generated code (Lombok, JPA proxies)
- Trivial getters and setters with no logic

## Coverage

Use coverage as a diagnostic indicator, not a target. A high-coverage suite with weak assertions is less valuable than a focused suite with strong ones.

Run coverage: `mvn test -Pcoverage` or `gradle jacocoTestReport` (if configured).

Focus coverage effort on packages containing business logic.

## Spring Boot Test Slices

When testing Spring Boot components, prefer slice tests over `@SpringBootTest` to speed up the test suite and limit the loaded context.

| Annotation | What it loads | Use for |
|---|---|---|
| `@WebMvcTest(MyController.class)` | Only the MVC layer (controllers, filters, security) | Testing HTTP contracts, request mapping, validation |
| `@DataJpaTest` | JPA repositories + embedded/test database | Testing queries, custom JPQL, Spring Data methods |
| `@RestClientTest(MyClient.class)` | `RestTemplate`/`WebClient` + mock server | Testing HTTP clients |
| `@SpringBootTest` | Full application context | End-to-end integration tests only |

Example of `@WebMvcTest`:

```java
@WebMvcTest(OrderController.class)
class OrderControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private OrderService orderService;

    @Test
    void returnsOrderWhenFound() throws Exception {
        when(orderService.getOrder("ord-1"))
            .thenReturn(new Order("ord-1", "customer-1", List.of()));

        mockMvc.perform(get("/orders/ord-1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value("ord-1"));
    }

    @Test
    void returns404WhenOrderNotFound() throws Exception {
        when(orderService.getOrder("ord-x"))
            .thenThrow(new OrderNotFoundException("ord-x"));

        mockMvc.perform(get("/orders/ord-x"))
            .andExpect(status().isNotFound());
    }
}
```

Example of `@DataJpaTest`:

```java
@DataJpaTest
class OrderRepositoryTest {

    @Autowired
    private OrderRepository repository;

    @Test
    void findsByCustomerId() {
        var order = repository.save(new Order(null, "customer-1", List.of()));

        var results = repository.findByCustomerId("customer-1");

        assertThat(results).hasSize(1);
        assertThat(results.get(0).id()).isEqualTo(order.id());
    }
}
```

Use `@MockBean` to replace real Spring beans with mocks in slice tests. Avoid `@SpringBootTest` for unit-level tests — it loads the entire context and is significantly slower.

## Running Tests

```sh
mvn test                             # all unit tests
mvn verify                           # unit + integration tests (failsafe)
mvn test -pl module-name             # specific Maven module
gradle test                          # all tests
gradle integrationTest               # integration tests (if task defined)
mvn test -Dtest=OrderControllerTest  # specific test class
```
