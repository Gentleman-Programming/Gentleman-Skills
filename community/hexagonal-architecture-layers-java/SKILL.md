---
name: hexagonal-architecture-layers-java
description: >
  Hexagonal architecture layering for Java services with strict boundaries.
  Trigger: When structuring Java apps by Domain/Application/Infrastructure, or refactoring toward clean architecture.
metadata:
  author: diegnghrmr
  version: "1.0"
---

## When to Use

Load this skill when:
- Designing a new Java service with clean, testable layers
- Refactoring Spring code to isolate the domain from frameworks
- Supporting multiple adapters (REST + messaging, JPA + Mongo)
- Enforcing dependency direction and clear module boundaries

## Critical Patterns

### Pattern 1: Domain is pure

Domain has no framework annotations, no persistence concerns, and no I/O.

### Pattern 2: Application orchestrates

Application defines use cases and ports, calling domain logic and delegating I/O to ports.

### Pattern 3: Infrastructure adapts

Infrastructure implements ports and wires adapters (controllers, repositories, clients).

## Code Examples

### Example 1: Domain model + output port

```java
package com.acme.order.domain;

public record OrderId(String value) { }

public final class Order {
  private final OrderId id;
  private final Money total;

  public Order(OrderId id, Money total) {
    this.id = id;
    this.total = total;
  }

  public OrderId id() { return id; }
  public Money total() { return total; }
}
```

```java
package com.acme.order.application.port;

import com.acme.order.domain.Order;
import com.acme.order.domain.OrderId;

public interface OrderRepositoryPort {
  OrderId nextId();
  void save(Order order);
}
```

### Example 2: Application use case + input port

```java
package com.acme.order.application.usecase;

import com.acme.order.application.port.OrderRepositoryPort;
import com.acme.order.domain.Order;
import com.acme.order.domain.OrderId;
import com.acme.order.domain.Money;

public interface PlaceOrderUseCase {
  OrderId place(Money total);
}

public final class PlaceOrderService implements PlaceOrderUseCase {
  private final OrderRepositoryPort repository;

  public PlaceOrderService(OrderRepositoryPort repository) {
    this.repository = repository;
  }

  @Override
  public OrderId place(Money total) {
    OrderId id = repository.nextId();
    Order order = new Order(id, total);
    repository.save(order);
    return id;
  }
}
```

### Example 3: Infrastructure adapter + wiring

```java
package com.acme.order.infrastructure.persistence;

import com.acme.order.application.port.OrderRepositoryPort;
import com.acme.order.domain.Order;
import com.acme.order.domain.OrderId;
import org.springframework.stereotype.Repository;

@Repository
public final class OrderJpaAdapter implements OrderRepositoryPort {
  private final SpringOrderRepository repository;
  private final OrderMapper mapper;

  public OrderJpaAdapter(SpringOrderRepository repository, OrderMapper mapper) {
    this.repository = repository;
    this.mapper = mapper;
  }

  @Override
  public OrderId nextId() {
    return new OrderId(java.util.UUID.randomUUID().toString());
  }

  @Override
  public void save(Order order) {
    repository.save(mapper.toEntity(order));
  }
}
```

## Anti-Patterns

### Don't: Put framework annotations in domain

```java
// BAD: domain tied to JPA
@jakarta.persistence.Entity
public class Order {
  @jakarta.persistence.Id
  private String id;
}
```

### Don't: Call infrastructure directly from domain

```java
// BAD: domain depends on Spring repository
public class Order {
  private final SpringOrderRepository repository;
}
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Persist domain data | Define output port in application, implement in infrastructure |
| Expose use case | Define input port and service in application |
| Keep domain pure | No annotations, no I/O, no framework imports |

## Resources

- Hexagonal Architecture: https://alistair.cockburn.us/hexagonal-architecture/
- Clean Architecture: https://www.oreilly.com/library/view/clean-architecture/9780134494272/
