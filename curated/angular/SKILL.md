---
name: angular
description: >
  Angular patterns with standalone components, signals, and Scope Rule architecture.
  Trigger: When working with Angular, creating components, managing state with signals, or structuring Angular projects.
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Creating Angular components or services
- Setting up Angular project structure
- Managing state with signals
- Deciding component placement (local vs shared)

---

## Critical Patterns

### Standalone Components (Default)

Components are standalone by default. Do NOT set `standalone: true` - it's implicit.

```typescript
@Component({
  selector: 'app-user-profile',
  imports: [ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `...`
})
export class UserProfileComponent {}
```

### Input/Output Functions

```typescript
// Required input
readonly user = input.required<User>();

// Optional input with default
readonly disabled = input(false);

// Output for events
readonly selected = output<User>();

// Two-way binding with model
readonly checked = model(false);
```

### Signals for State

```typescript
// Writable signal
readonly count = signal(0);

// Update with set() or update()
this.count.set(5);
this.count.update(prev => prev + 1);

// Derived state with computed()
readonly doubled = computed(() => this.count() * 2);

// Side effects with effect()
effect(() => localStorage.setItem('count', this.count().toString()));
```

### inject() Over Constructor

```typescript
private readonly http = inject(HttpClient);
private readonly router = inject(Router);
```

### Native Control Flow

```typescript
@if (loading()) {
  <spinner />
} @else {
  @for (item of items(); track item.id) {
    <item-card [data]="item" />
  } @empty {
    <p>No items found</p>
  }
}

@switch (status()) {
  @case ('active') { <span>Active</span> }
  @case ('inactive') { <span>Inactive</span> }
  @default { <span>Unknown</span> }
}
```

### Host Bindings in Decorator

```typescript
// Do NOT use @HostBinding/@HostListener
@Component({
  host: {
    '[class.active]': 'isActive()',
    '(click)': 'onClick($event)'
  }
})
```

---

## The Scope Rule

**"Scope determines structure"** - This is absolute.

| Usage | Placement |
|-------|-----------|
| 1 feature | Local: `features/[feature]/components/` |
| 2+ features | Shared: `features/shared/components/` |

```
features/
  shopping-cart/
    shopping-cart.ts          # Main component = feature name
    components/
      cart-item.ts            # Used ONLY by shopping-cart
  shared/
    components/
      button.ts               # Used by 2+ features
```

---

## Project Structure

```
src/app/
  features/
    [feature-name]/
      [feature-name].ts       # Main standalone component
      components/             # Feature-specific components
      services/               # Feature-specific services
      models/                 # Feature-specific types
    shared/                   # ONLY for 2+ feature usage
      components/
      services/
      pipes/
  core/                       # Singleton services
    services/
    interceptors/
    guards/
  app.ts
  app.config.ts
  routes.ts
  main.ts
```

---

## Code Examples

### Component with Signals

```typescript
import { Component, ChangeDetectionStrategy, signal, computed, input, output, inject } from '@angular/core';

@Component({
  selector: 'app-product-list',
  imports: [CurrencyPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (loading()) {
      <div class="spinner">Loading...</div>
    } @else {
      @for (product of filtered(); track product.id) {
        <div (click)="select(product)">
          <h3>{{ product.name }}</h3>
          <p>{{ product.price | currency }}</p>
        </div>
      } @empty {
        <p>No products found</p>
      }
    }
  `
})
export class ProductListComponent {
  readonly category = input<string>();
  readonly products = input.required<Product[]>();
  readonly productSelected = output<Product>();
  
  private readonly _loading = signal(false);
  readonly loading = this._loading.asReadonly();
  
  readonly filtered = computed(() => {
    const cat = this.category();
    return cat ? this.products().filter(p => p.category === cat) : this.products();
  });
  
  select(product: Product): void {
    this.productSelected.emit(product);
  }
}
```

### Service with Signal State

```typescript
@Injectable({ providedIn: 'root' })
export class CartService {
  private readonly http = inject(HttpClient);
  
  private readonly state = signal<{ items: CartItem[]; loading: boolean }>({
    items: [],
    loading: false
  });
  
  readonly items = computed(() => this.state().items);
  readonly loading = computed(() => this.state().loading);
  readonly total = computed(() => this.items().reduce((sum, i) => sum + i.price * i.qty, 0));
  
  addItem(item: CartItem): void {
    this.state.update(s => ({ ...s, items: [...s.items, item] }));
  }
  
  removeItem(id: string): void {
    this.state.update(s => ({ ...s, items: s.items.filter(i => i.id !== id) }));
  }
}
```

### Lazy Routes

```typescript
export const routes: Routes = [
  { path: '', loadComponent: () => import('./features/home/home').then(m => m.HomeComponent) },
  { path: 'products', loadComponent: () => import('./features/products/products').then(m => m.ProductsComponent) },
  { path: 'cart', loadComponent: () => import('./features/cart/cart').then(m => m.CartComponent), canActivate: [authGuard] }
];
```

### Typed Reactive Forms

```typescript
@Component({
  selector: 'app-login-form',
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="submit()">
      <input formControlName="email" type="email" />
      <input formControlName="password" type="password" />
      <button type="submit" [disabled]="form.invalid">Login</button>
    </form>
  `
})
export class LoginFormComponent {
  private readonly fb = inject(FormBuilder);
  
  readonly form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]]
  });
  
  submit(): void {
    if (this.form.valid) {
      const { email, password } = this.form.getRawValue();
    }
  }
}
```

---

## Anti-Patterns

| Don't | Do |
|-------|-----|
| `@NgModule` | Standalone components |
| `@Input()` decorator | `input()` function |
| `@Output()` decorator | `output()` function |
| `*ngIf`, `*ngFor` | `@if`, `@for` |
| `ngClass`, `ngStyle` | `[class]`, `[style]` bindings |
| Constructor injection | `inject()` function |
| `@HostBinding` | `host` object in decorator |
| `any` type | Proper types |
| Arrow functions in templates | Component methods |

---

## Commands

```bash
# Create new project
ng new my-app --style=scss --ssr=false

# Generate component
ng g c features/products/components/product-card --flat

# Generate service
ng g s features/products/services/product --flat

# Generate guard
ng g g core/guards/auth --functional
```

---

## File Naming

No `.component`, `.service` suffixes - the name tells the behavior:

```
user-profile.ts     # Not user-profile.component.ts
cart.ts             # Not cart.service.ts
user.ts             # Not user.model.ts
```

---

## Quick Reference

| Old Pattern | Modern Angular |
|-------------|----------------|
| `@Input()` | `input()` / `input.required()` |
| `@Output()` | `output()` |
| `*ngIf` | `@if` |
| `*ngFor` | `@for` (requires `track`) |
| `*ngSwitch` | `@switch` |
| `constructor(private svc)` | `inject(Service)` |
| `BehaviorSubject` | `signal()` |
| `combineLatest` | `computed()` |
| `tap` side effects | `effect()` |
| `NgModule` | Standalone component |

## Resources

- [Angular Signals](https://angular.dev/guide/signals)
- [Standalone Components](https://angular.dev/guide/components/importing)
- [Control Flow](https://angular.dev/guide/templates/control-flow)
- [AI Development Guide](https://angular.dev/ai/develop-with-ai)
