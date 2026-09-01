# Java Security Guidance

## General Posture

Security is not a post-processing step. Review every change against this checklist before declaring a task complete. Flag any concern found — even if the task did not explicitly mention security.

## Input Validation

- Validate all external input at the system boundary (controllers, message consumers, CLI entry points).
- Use Bean Validation (`@NotBlank`, `@Size`, `@Pattern`, `@Valid`) for HTTP request bodies and parameters.
- Reject inputs that exceed expected sizes or contain invalid characters before processing them.
- Never trust input from headers, query parameters, path variables, or request bodies without validation.

## SQL Injection

Always use parameterized queries or JPA's type-safe API:

```java
// Incorrect — SQL injection risk:
String query = "SELECT * FROM users WHERE email = '" + email + "'";
entityManager.createNativeQuery(query).getResultList();

// Correct — parameterized:
entityManager.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
    .setParameter("email", email)
    .getResultList();

// Correct — Spring Data JPA:
userRepository.findByEmail(email);

// Correct — JDBC:
PreparedStatement stmt = connection.prepareStatement("SELECT * FROM users WHERE email = ?");
stmt.setString(1, email);
```

Never concatenate user input into JPQL, HQL, or native SQL strings.

## XSS (Cross-Site Scripting)

- When returning HTML (Thymeleaf, JSP), always escape user-controlled content. Thymeleaf escapes by default with `th:text`; use `th:utext` only for trusted HTML.
- When returning JSON via `@ResponseBody` or `@RestController`, do not render it as HTML.
- Set `Content-Type: application/json` explicitly on JSON responses.
- Set security headers via a security filter or Spring Security:
  ```
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Content-Security-Policy: default-src 'self'
  ```

## CSRF

- If using Spring Security, CSRF protection is enabled by default for stateful applications. Do not disable it without a clear reason.
- For stateless REST APIs using JWT or API keys, CSRF protection can be disabled appropriately.
- Use `SameSite=Strict` or `SameSite=Lax` on session cookies.

## Deserialization

- Never deserialize untrusted data with `ObjectInputStream` — this is a known critical vulnerability class.
- When using Jackson, configure `ObjectMapper` to disallow polymorphic type handling from untrusted sources:
  ```java
  objectMapper.activateDefaultTyping(
      LaissezFaireSubTypeValidator.instance,
      ObjectMapper.DefaultTyping.NONE  // or restrict to trusted types
  );
  ```
- Prefer DTOs with explicit fields over generic `Map<String, Object>` deserialization.

## SSRF (Server-Side Request Forgery)

- Never make HTTP requests to URLs provided directly by users without validation.
- Validate that outgoing URLs match an allowlist of expected hostnames.
- Restrict network access from the application to only what is needed (firewall rules, VPC policies).

## Path Traversal

When constructing file paths from user input, canonicalize and validate against an allowed base:

```java
Path base = Paths.get("/var/uploads").toRealPath();
Path target = base.resolve(userFileName).normalize();
if (!target.startsWith(base)) {
    throw new SecurityException("path traversal detected");
}
```

## Secrets Management

- Never store secrets (passwords, API keys, private keys, tokens) in source code, properties files committed to version control, or application logs.
- Use environment variables, Spring Cloud Config, Vault, or the platform's secrets manager.
- Annotate secret fields with `@JsonIgnore` or equivalent to prevent accidental serialization.
- Use `char[]` instead of `String` for passwords in memory where possible.

## Dependency Security

- Run OWASP Dependency Check in CI (`mvn dependency-check:check` or Gradle equivalent).
- Review CVEs when updating dependencies.
- Keep Spring Boot, Spring Security, and JDBC drivers up to date.

## Error Exposure

- Do not return stack traces, internal exception messages, or database error details to API clients.
- Use `@ExceptionHandler` or `@ControllerAdvice` to return generic error responses externally:
  ```java
  @ExceptionHandler(Exception.class)
  @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
  public ErrorResponse handleUnexpected(Exception e) {
      log.error("unexpected error", e);
      return new ErrorResponse("internal server error");
  }
  ```

## Authentication and Authorization

- Use Spring Security for authentication and authorization — do not implement custom session management.
- Protect sensitive endpoints with appropriate `@PreAuthorize` or HTTP security rules.
- Use strong password hashing: `BCryptPasswordEncoder` or `Argon2PasswordEncoder`.
- Never compare passwords as plain strings — always use the `matches` method of a `PasswordEncoder`.
- Invalidate sessions on logout: `SecurityContextHolder.clearContext()`.

## Logging

- Do not log passwords, tokens, credit card numbers, or other sensitive data — even at `DEBUG` level.
- Use structured logging with correlation IDs for tracing across services.
- Sanitize user-provided values before including them in log messages to prevent log injection.

## Security Review Checklist

Before completing any task involving HTTP endpoints, database access, file handling, or user input:

- [ ] All queries use parameterized inputs or JPA type-safe API
- [ ] No user input is concatenated into JPQL, HQL, or native SQL
- [ ] Input is validated with Bean Validation or explicit checks
- [ ] XSS protections are in place for HTML responses
- [ ] CSRF is enabled for stateful applications
- [ ] No `ObjectInputStream` used with untrusted data
- [ ] File paths from user input are validated against allowed directories
- [ ] No secrets in source code or committed configuration files
- [ ] Error responses do not expose stack traces or internal details
- [ ] OWASP Dependency Check passes in CI
