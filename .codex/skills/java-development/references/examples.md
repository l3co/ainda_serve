# Java Idiomatic Examples

Short, focused examples. Not a complete application — reference patterns only.

---

## Value Object with Record

```java
// Immutable value object — equality by value, not identity.
public record Money(long amountInCents, Currency currency) {

    public Money {
        if (amountInCents < 0) {
            throw new IllegalArgumentException("amount must be non-negative");
        }
        Objects.requireNonNull(currency, "currency must not be null");
    }

    public Money add(Money other) {
        if (!this.currency.equals(other.currency)) {
            throw new IllegalArgumentException("cannot add different currencies");
        }
        return new Money(this.amountInCents + other.amountInCents, this.currency);
    }
}
```

---

## Domain Service

```java
// Pure domain service — no persistence, no HTTP, no Spring annotations.
public class OrderPricingService {

    public Money calculateTotal(List<OrderItem> items, DiscountPolicy discount) {
        var subtotal = items.stream()
            .map(item -> item.unitPrice().multiply(item.quantity()))
            .reduce(Money.ZERO_BRL, Money::add);
        return discount.apply(subtotal);
    }
}
```

---

## Exception Handling

```java
// Application service — translates domain exceptions to application-level ones.
public Order placeOrder(PlaceOrderCommand command) {
    var customer = customerRepository.findById(command.customerId())
        .orElseThrow(() -> new CustomerNotFoundException(command.customerId()));

    var order = orderFactory.create(customer, command.items());

    try {
        return orderRepository.save(order);
    } catch (DataIntegrityViolationException e) {
        throw new OrderPersistenceException("failed to persist order for customer " + customer.id(), e);
    }
}
```

---

## Interface Segregation

```java
// Consuming package defines only what it needs.
public interface OrderReader {
    Optional<Order> findById(String orderId);
    List<Order> findByCustomerId(String customerId);
}

public interface OrderWriter {
    Order save(Order order);
    void delete(String orderId);
}

// The service only depends on what it uses:
public class OrderQueryService {
    private final OrderReader reader;

    public OrderQueryService(OrderReader reader) {
        this.reader = reader;
    }
}
```

---

## Sealed Class for Domain State

```java
// Exhaustive result type — compiler enforces all cases are handled.
public sealed interface PaymentResult
    permits PaymentResult.Approved, PaymentResult.Declined, PaymentResult.Pending {

    record Approved(String transactionId) implements PaymentResult {}
    record Declined(String reason) implements PaymentResult {}
    record Pending(String referenceId) implements PaymentResult {}
}

// Pattern matching in the consumer:
String describe(PaymentResult result) {
    return switch (result) {
        case PaymentResult.Approved a -> "Approved: " + a.transactionId();
        case PaymentResult.Declined d -> "Declined: " + d.reason();
        case PaymentResult.Pending p  -> "Pending: " + p.referenceId();
    };
}
```

---

## JUnit 5 Parameterized Test

```java
class MoneyTest {

    @ParameterizedTest(name = "{0} + {1} = {2} cents")
    @MethodSource("additionCases")
    void addsMoneyCorrectly(long a, long b, long expected) {
        var result = new Money(a, Currency.BRL).add(new Money(b, Currency.BRL));
        assertThat(result.amountInCents()).isEqualTo(expected);
    }

    static Stream<Arguments> additionCases() {
        return Stream.of(
            Arguments.of(100L, 200L, 300L),
            Arguments.of(0L, 500L, 500L),
            Arguments.of(999L, 1L, 1000L)
        );
    }

    @Test
    void throwsWhenAddingDifferentCurrencies() {
        var brl = new Money(100, Currency.BRL);
        var usd = new Money(100, Currency.USD);

        assertThatThrownBy(() -> brl.add(usd))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("currencies");
    }
}
```

---

## Over-Engineering vs. Simplicity

### Overly complex (avoid)

```java
// Three classes for a simple calculation with one implementation.
public interface TaxCalculationStrategy {
    BigDecimal calculate(BigDecimal subtotal);
}

public class StandardTaxCalculationStrategy implements TaxCalculationStrategy {
    @Override
    public BigDecimal calculate(BigDecimal subtotal) {
        return subtotal.multiply(BigDecimal.valueOf(0.10));
    }
}

public class TaxCalculationStrategyFactory {
    public TaxCalculationStrategy create(TaxType type) {
        return new StandardTaxCalculationStrategy(); // only one case
    }
}
```

### Simplified (prefer)

```java
// When there is only one strategy and no extension point needed.
BigDecimal calculateTax(BigDecimal subtotal) {
    return subtotal.multiply(BigDecimal.valueOf(0.10));
}
```

---

## Optional Usage

```java
// Correct: Optional as return type for "may be absent" semantics.
public Optional<Customer> findCustomerByEmail(String email) {
    return customerRepository.findByEmail(email);
}

// Correct: process without exposing null.
findCustomerByEmail(email)
    .map(Customer::fullName)
    .ifPresent(name -> log.info("Found customer: {}", name));

// Incorrect: Optional as parameter (forces callers to wrap values).
// public Order createOrder(Optional<String> couponCode) { ... }  ← avoid
```

---

## Constructor Injection

```java
// Correct: dependencies declared in constructor, immutable fields.
@Service
public class NotificationService {

    private final EmailSender emailSender;
    private final SmsGateway smsGateway;

    public NotificationService(EmailSender emailSender, SmsGateway smsGateway) {
        this.emailSender = Objects.requireNonNull(emailSender);
        this.smsGateway = Objects.requireNonNull(smsGateway);
    }
}

// Incorrect: field injection hides dependencies, makes testing harder.
// @Autowired
// private EmailSender emailSender;  ← avoid
```

---

## Java-Specific Anti-Patterns

### Swallowed Exception

```java
// Anti-pattern: empty catch block hides failures permanently.
try {
    sendNotification(userId);
} catch (Exception e) {
    // silently ignored
}

// Correct: log and decide whether to propagate or handle.
try {
    sendNotification(userId);
} catch (NotificationDeliveryException e) {
    log.warn("notification delivery failed for user {}, will retry", userId, e);
    retryQueue.enqueue(userId);
}
```

### Checked Exception Wrapping Without Context

```java
// Anti-pattern: wraps without adding information.
try {
    repository.save(order);
} catch (SQLException e) {
    throw new RuntimeException(e); // caller gets no context
}

// Correct: wrap with context.
try {
    repository.save(order);
} catch (SQLException e) {
    throw new OrderPersistenceException("failed to save order " + order.id(), e);
}
```

### Optional as Parameter

```java
// Anti-pattern: forces callers to wrap values unnecessarily.
public Order createOrder(String customerId, Optional<String> couponCode) { ... }

// Correct: use method overloading or a nullable parameter with @Nullable.
public Order createOrder(String customerId) { ... }
public Order createOrder(String customerId, String couponCode) { ... }
```

### Service That Only Delegates

```java
// Anti-pattern: no behavior added — just pass-through.
@Service
public class OrderApplicationService {
    public Order createOrder(CreateOrderCommand command) {
        return orderDomainService.createOrder(command); // does nothing else
    }
}

// When there is no orchestration, cross-cutting logic, or transaction management to add,
// callers should call the domain service directly.
```

### Stream Too Complex to Read

```java
// Anti-pattern: nested streams with mixed concerns.
orders.stream()
    .filter(o -> o.status() == ACTIVE)
    .flatMap(o -> o.items().stream())
    .filter(i -> i.category().equals("electronics"))
    .collect(groupingBy(Item::supplierId,
        summingLong(i -> i.priceInCents() * i.quantity())));

// Correct: extract intermediate steps with meaningful names.
var activeOrders = orders.stream().filter(o -> o.status() == ACTIVE).toList();
var electronicsItems = activeOrders.stream()
    .flatMap(o -> o.items().stream())
    .filter(i -> i.category().equals("electronics"))
    .toList();
var totalBySupplier = electronicsItems.stream()
    .collect(groupingBy(Item::supplierId, summingLong(i -> i.priceInCents() * i.quantity())));
```
