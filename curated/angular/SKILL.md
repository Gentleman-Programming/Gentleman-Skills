---
name: angular
description: >
  Angular patterns with signals, standalone components, zoneless, and Scope Rule architecture.
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
readonly count = signal(0);
readonly doubled = computed(() => this.count() * 2);

// Update with set() or update()
this.count.set(5);
this.count.update(prev => prev + 1);

// Side effects
effect(() => localStorage.setItem('count', this.count().toString()));
```

---

## inject() Over Constructor (REQUIRED)

```typescript
// ✅ ALWAYS
private readonly http = inject(HttpClient);

// ❌ NEVER
constructor(private http: HttpClient) {}
```

---

## Native Control Flow (REQUIRED)

```typescript
@if (loading()) {
  <spinner />
} @else {
  @for (item of items(); track item.id) {
    <item-card [data]="item" />
  } @empty {
    <p>No items</p>
  }
}
```

---

## Zoneless Angular (REQUIRED)

Angular is zoneless. Use `provideZonelessChangeDetection()` and remove ZoneJS.

```typescript
bootstrapApplication(AppComponent, {
  providers: [provideZonelessChangeDetection()]
});
```

Remove from `angular.json` polyfills and uninstall:
```bash
npm uninstall zone.js
```

### Zoneless Requirements
- Use `OnPush` change detection
- Use signals for state (auto-notifies Angular)
- Use `AsyncPipe` for observables
- Use `markForCheck()` when needed

---

## Forms - Signal Forms vs Reactive

| Use Case | Recommendation |
|----------|----------------|
| New apps with signals | Signal Forms (experimental) |
| Production apps | Reactive Forms |
| Simple forms | Template-driven |

### Signal Forms (v21+, experimental)

```typescript
import { form, FormField, required } from '@angular/forms/signals';

@Component({
  imports: [FormField],
  template: `<input [formField]="emailField" />`
})
export class LoginComponent {
  readonly loginForm = form({
    email: ['', required],
    password: ['', required]
  });
  
  readonly emailField = this.loginForm.controls.email;
}
```

### Reactive Forms (production)

```typescript
private readonly fb = inject(FormBuilder);

form = this.fb.nonNullable.group({
  email: ['', [Validators.required, Validators.email]],
  password: ['', Validators.required],
});
```

---

## Performance

### NgOptimizedImage (REQUIRED for images)

```typescript
import { NgOptimizedImage } from '@angular/common';

@Component({
  imports: [NgOptimizedImage],
  template: `
    <!-- LCP image: add priority -->
    <img ngSrc="hero.jpg" width="800" height="400" priority>
    
    <!-- Regular: lazy loaded by default -->
    <img ngSrc="thumb.jpg" width="200" height="200">
    
    <!-- Fill mode (parent needs position: relative) -->
    <img ngSrc="bg.jpg" fill>
  `
})
```

**Rules:**
- ALWAYS set `width` and `height` (or `fill`)
- Add `priority` to LCP image
- Use `ngSrc` not `src`

### Slow Computations

| Solution | When |
|----------|------|
| Optimize algorithm | First choice always |
| Pure pipes | Cache single result |
| Memoization | Cache multiple results |

**NEVER** trigger reflows in lifecycle hooks.

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
      [feature-name].ts
      components/
      services/
    shared/
      components/
      services/
  core/
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
```

---

## Style Guide

### From Official Docs (that we follow)
- `inject()` over constructor injection
- `class` and `style` bindings over `ngClass`/`ngStyle`
- `protected` for template-only members
- `readonly` for inputs, outputs, queries
- Name handlers for action (`saveUser`) not event (`handleClick`)
- Keep lifecycle hooks simple - delegate to well-named methods

### We Override
- File naming: NO suffixes (official says `.component.ts`)

---

## SSR & Hydration

```typescript
bootstrapApplication(AppComponent, {
  providers: [
    provideClientHydration()
  ]
});
```

| Scenario | Use |
|----------|-----|
| SEO critical | SSR |
| Dashboard/Admin | CSR |
| Static site | SSG/Prerender |

---

## @defer - Lazy Components

```html
@defer (on viewport) {
  <heavy-component />
} @placeholder {
  <p>Placeholder</p>
} @loading (minimum 200ms) {
  <spinner />
} @error {
  <p>Failed</p>
}
```

| Trigger | When |
|---------|------|
| `on viewport` | Below the fold |
| `on interaction` | On click/focus |
| `on idle` | Browser idle |
| `on timer(ms)` | After delay |
| `when condition` | Expression true |

---

## Lazy Routes

```typescript
{
  path: 'admin',
  loadComponent: () => import('./features/admin/admin').then(c => c.AdminComponent)
}

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
