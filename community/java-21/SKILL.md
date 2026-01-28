---
name: java-21
description: >
  Java 21 language and runtime patterns for modern, safe code.
  Trigger: When writing Java 21 code using records, sealed types, or virtual threads.
metadata:
  author: diegnghrmr
  version: "1.0"
---

## When to Use

Load this skill when:
- Writing Java 21 application or library code
- Designing immutable DTOs or value objects
- Modeling closed hierarchies with sealed types
- Using virtual threads for blocking I/O

## Critical Patterns

### Pattern 1: Records for immutable data

Use records for DTOs and value objects, validate in compact constructors.

### Pattern 2: Sealed types + pattern matching

Use sealed interfaces/classes and switch pattern matching for exhaustiveness.

### Pattern 3: Virtual threads for I/O

Use virtual threads to handle blocking I/O without large thread pools.

## Code Examples

### Example 1: Record with validation

```java
package com.acme.user;

public record Email(String value) {
  public Email {
    if (value == null || !value.contains("@")) {
      throw new IllegalArgumentException("Invalid email");
    }
  }
}
```

### Example 2: Sealed hierarchy + switch pattern matching

```java
package com.acme.payment;

public sealed interface Payment permits Card, BankTransfer { }

public record Card(String last4) implements Payment { }
public record BankTransfer(String iban) implements Payment { }

public final class PaymentPrinter {
  public String describe(Payment payment) {
    return switch (payment) {
      case Card card -> "card-" + card.last4();
      case BankTransfer bank -> "iban-" + bank.iban();
    };
  }
}
```

### Example 3: Virtual threads for blocking calls

```java
package com.acme.io;

import java.util.concurrent.Executors;

public final class Fetcher {
  public void fetchAll(java.util.List<String> urls) throws Exception {
    try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
      for (String url : urls) {
        executor.submit(() -> blockingFetch(url));
      }
    }
  }

  private void blockingFetch(String url) {
    // perform blocking I/O here
  }
}
```

## Anti-Patterns

### Don't: Use mutable data carriers

```java
// BAD: mutable DTO
public class UserDto {
  public String name;
  public String email;
}
```

### Don't: Spin up raw platform threads per request

```java
// BAD: expensive and unbounded
new Thread(() -> blockingFetch("https://api" )).start();
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Immutable DTOs | Use records with validation |
| Closed hierarchies | Use sealed interfaces + switch |
| Blocking I/O scale | Use virtual threads executor |

## Resources

- Java 21 Release Notes: https://www.oracle.com/java/technologies/javase/21-relnote-issues.html
- JEP Index: https://openjdk.org/jeps/0
