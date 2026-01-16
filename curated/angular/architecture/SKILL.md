---
name: angular-architecture
description: >
  Angular architecture: Scope Rule, project structure, file naming, style guide.
  Trigger: When structuring Angular projects or deciding where to place components.
metadata:
  author: gentleman-programming
  version: "1.0"
---

## The Scope Rule (REQUIRED)

**"Scope determines structure"** - Where a component lives depends on its usage.

| Usage | Placement |
|-------|-----------|
| Used by 1 feature | `features/[feature]/components/` |
| Used by 2+ features | `features/shared/components/` |

### Example

```
features/
  shopping-cart/
    shopping-cart.ts          # Main component = feature name
    components/
      cart-item.ts            # Used ONLY by shopping-cart
      cart-summary.ts         # Used ONLY by shopping-cart
  checkout/
    checkout.ts
    components/
      payment-form.ts         # Used ONLY by checkout
  shared/
    components/
      button.ts               # Used by shopping-cart AND checkout
      modal.ts                # Used by multiple features
```

---

## Project Structure

```
src/app/
  features/
    [feature-name]/
      [feature-name].ts       # Main component (same name as folder)
      components/             # Feature-specific components
      services/               # Feature-specific services
      models/                 # Feature-specific types
    shared/                   # ONLY for 2+ feature usage
      components/
      services/
      pipes/
  core/                       # App-wide singletons
    services/
    interceptors/
    guards/
  app.ts
  app.config.ts
  routes.ts
  main.ts
```

---

## File Naming (REQUIRED)

No `.component`, `.service`, `.model` suffixes. The folder tells you what it is.

```
✅ user-profile.ts
❌ user-profile.component.ts

✅ cart.ts
❌ cart.service.ts

✅ user.ts
❌ user.model.ts
```

---

## Style Guide

### What We Follow (from official docs)

- `inject()` over constructor injection
- `class` and `style` bindings over `ngClass`/`ngStyle`
- `protected` for template-only members
- `readonly` for inputs, outputs, queries
- Name handlers for action (`saveUser`) not event (`handleClick`)
- Keep lifecycle hooks simple - delegate to well-named methods
- One concept per file

```typescript
@Component({...})
export class UserProfileComponent {
  // 1. Injected dependencies
  private readonly userService = inject(UserService);
  
  // 2. Inputs/Outputs
  readonly userId = input.required<string>();
  readonly userSaved = output<User>();
  
  // 3. Internal state
  private readonly _loading = signal(false);
  readonly loading = this._loading.asReadonly();
  
  // 4. Computed
  protected readonly displayName = computed(() => ...);
  
  // 5. Methods
  save(): void { ... }
}
```

### What We Override

| Official Says | We Do | Why |
|---------------|-------|-----|
| `user-profile.component.ts` | `user-profile.ts` | Redundant - folder tells context |
| `user.service.ts` | `user.ts` | Same |

---

## Commands

```bash
# New project
ng new my-app --style=scss --ssr=false

# Component in feature
ng g c features/products/components/product-card --flat

# Service in feature  
ng g s features/products/services/product --flat

# Guard in core
ng g g core/guards/auth --functional
```

---

## Resources

- https://angular.dev/style-guide
