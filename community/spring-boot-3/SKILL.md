---
name: spring-boot-3
description: >
  Spring Boot 3 patterns for configuration, DI, and web services.
  Trigger: When building or refactoring Spring Boot 3 applications.
metadata:
  author: diegnghrmr
  version: "1.0"
---

## When to Use

Load this skill when:
- Building a Spring Boot 3.3+ service or API
- Wiring beans with dependency injection
- Defining configuration properties and validation
- Implementing REST controllers and service layers

## Critical Patterns

### Pattern 1: Constructor injection only

Always use constructor injection; avoid field injection.

### Pattern 2: Typed configuration properties

Use @ConfigurationProperties with validation, not scattered @Value.

### Pattern 3: Transaction boundaries at service layer

Apply @Transactional on application services, not controllers.

## Code Examples

### Example 1: Configuration properties with validation

```java
package com.acme.config;

import jakarta.validation.constraints.NotBlank;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "payment")
public record PaymentProperties(
  @NotBlank String provider,
  @NotBlank String apiKey
) { }
```

```java
package com.acme;

import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@ConfigurationPropertiesScan
public class Application { }
```

### Example 2: Service with constructor injection + transaction

```java
package com.acme.order.application;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public final class OrderService {
  private final OrderRepository repository;

  public OrderService(OrderRepository repository) {
    this.repository = repository;
  }

  @Transactional
  public void placeOrder(OrderCommand command) {
    repository.save(command.toEntity());
  }
}
```

### Example 3: REST controller with DTO records

```java
package com.acme.order.api;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/orders")
public final class OrderController {
  private final OrderService service;

  public OrderController(OrderService service) {
    this.service = service;
  }

  @PostMapping
  public ResponseEntity<OrderResponse> place(@RequestBody OrderRequest request) {
    service.placeOrder(request.toCommand());
    return ResponseEntity.ok(new OrderResponse("ok"));
  }

  public record OrderRequest(String sku, int qty) {
    public OrderCommand toCommand() { return new OrderCommand(sku, qty); }
  }

  public record OrderResponse(String status) { }
}
```

## Anti-Patterns

### Don't: Use field injection

```java
// BAD: field injection
@Service
public class OrderService {
  @org.springframework.beans.factory.annotation.Autowired
  private OrderRepository repository;
}
```

### Don't: Scatter configuration with @Value

```java
// BAD: hard to validate and test
@Service
public class PaymentService {
  @org.springframework.beans.factory.annotation.Value("${payment.apiKey}")
  private String apiKey;
}
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Inject dependencies | Constructor injection only |
| Read config | @ConfigurationProperties + @Validated |
| Transactions | @Transactional on services |

## Resources

- Spring Boot Reference: https://docs.spring.io/spring-boot/docs/current/reference/html/
- Spring Framework Reference: https://docs.spring.io/spring-framework/reference/
