---
name: angular
description: >
  Angular patterns with signals, standalone components, and Scope Rule architecture.
  Trigger: When working with Angular components, services, signals, or project structure.
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Standalone Components (REQUIRED)

Components are standalone by default. Do NOT set `standalone: true`.

```typescript
@Component({
  selector: 'app-user',
  imports: [ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `...`
})
export class UserComponent {}
```

---

## Input/Output Functions (REQUIRED)

```typescript
// ✅ ALWAYS: Function-based
readonly user = input.required<User>();
readonly disabled = input(false);
readonly selected = output<User>();
readonly checked = model(false);  // Two-way binding

// ❌ NEVER: Decorators
@Input() user: User;
@Output() selected = new EventEmitter<User>();
```

---

## Signals for State (REQUIRED)

```typescript
// ✅ ALWAYS: Signals
readonly count = signal(0);
readonly doubled = computed(() => this.count() * 2);

// Update with set() or update()
this.count.set(5);
this.count.update(prev => prev + 1);

// Side effects
effect(() => localStorage.setItem('count', this.count().toString()));

// ❌ NEVER: Plain properties for reactive state
count = 0;
```

---

## inject() Over Constructor (REQUIRED)

```typescript
// ✅ ALWAYS
private readonly http = inject(HttpClient);
private readonly router = inject(Router);

// ❌ NEVER
constructor(private http: HttpClient) {}
```

---

## Native Control Flow (REQUIRED)

```typescript
// ✅ ALWAYS: @if, @for, @switch
@if (loading()) {
  <spinner />
} @else {
  @for (item of items(); track item.id) {
    <item-card [data]="item" />
  } @empty {
    <p>No items</p>
  }
}

// ❌ NEVER: Structural directives
*ngIf="loading"
*ngFor="let item of items"
```

---

## Host Bindings in Decorator (REQUIRED)

```typescript
// ✅ ALWAYS: host object
@Component({
  host: {
    '[class.active]': 'isActive()',
    '(click)': 'onClick($event)'
  }
})

// ❌ NEVER: Decorators
@HostBinding('class.active') isActive = true;
@HostListener('click') onClick() {}
```

---

## The Scope Rule (REQUIRED)

**"Scope determines structure"** - Where a component lives depends on its usage.

| Usage | Placement |
|-------|-----------|
| 1 feature | `features/[feature]/components/` |
| 2+ features | `features/shared/components/` |

---

## Project Structure

```
src/app/
  features/
    [feature-name]/
      [feature-name].ts       # Main component
      components/             # Feature-specific
      services/
    shared/                   # ONLY for 2+ feature usage
      components/
      services/
  core/                       # Singletons
    services/
    guards/
  app.ts
  app.config.ts
  routes.ts
```

---

## File Naming (REQUIRED)

No `.component`, `.service` suffixes:

```
user-profile.ts     # Not user-profile.component.ts
cart.ts             # Not cart.service.ts
user.ts             # Not user.model.ts
```

---

## OnPush Change Detection (REQUIRED)

ALWAYS use `OnPush` - aligns with signals and future Zoneless Angular.

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
})
```

---

## SSR vs CSR - When to Use

| Scenario | Use | Why |
|----------|-----|-----|
| SEO critical (blog, e-commerce) | SSR | Search engines see content |
| Dynamic content, personalized | SSR | Fresh data per request |
| Dashboard, admin panel | CSR | No SEO needed, faster dev |
| Static marketing site | SSG/Prerender | Best performance |

```typescript
// Enable SSR + Hydration
bootstrapApplication(AppComponent, {
  providers: [
    provideClientHydration()
  ]
});
```

---

## @defer - Lazy Load Components

Use `@defer` for below-the-fold content or heavy components.

| Trigger | When to Use |
|---------|-------------|
| `on viewport` | Content not immediately visible |
| `on interaction` | Load on click/focus/hover |
| `on idle` | Load when browser is idle |
| `on timer(ms)` | Load after delay |
| `when condition` | Load when expression is true |

```html
@defer (on viewport) {
  <heavy-component />
} @placeholder {
  <p>Placeholder content</p>
} @loading (minimum 200ms) {
  <spinner />
} @error {
  <p>Failed to load</p>
}
```

---

## Lazy Loading Routes

```typescript
// Single component
{
  path: 'admin',
  loadComponent: () => import('./features/admin/admin').then(c => c.AdminComponent)
}

// Feature with child routes
{
  path: 'users',
  loadChildren: () => import('./features/users/routes').then(m => m.USERS_ROUTES)
}
```

---

## Commands

```bash
ng new my-app --style=scss --ssr=false
ng g c features/products/components/product-card --flat
ng g s features/products/services/product --flat
ng g g core/guards/auth --functional
```

---

## Resources

- **Examples**: See [assets/](assets/) for component and service templates
- **Documentation**: See [references/angular-docs.md](references/angular-docs.md) for official Angular docs
