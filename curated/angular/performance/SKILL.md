---
name: angular-performance
description: >
  Angular performance: NgOptimizedImage, @defer, lazy loading, SSR.
  Trigger: When optimizing Angular app performance, images, or lazy loading.
metadata:
  author: gentleman-programming
  version: "1.0"
---

## NgOptimizedImage (REQUIRED for images)

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
    
    <!-- With placeholder -->
    <img ngSrc="photo.jpg" width="400" height="300" placeholder>
  `
})
```

### Rules
- ALWAYS set `width` and `height` (or `fill`)
- Add `priority` to LCP (Largest Contentful Paint) image
- Use `ngSrc` not `src`
- Parent of `fill` image must have `position: relative/fixed/absolute`

---

## @defer - Lazy Components

```html
@defer (on viewport) {
  <heavy-component />
} @placeholder {
  <p>Placeholder shown immediately</p>
} @loading (minimum 200ms) {
  <spinner />
} @error {
  <p>Failed to load</p>
}
```

### Triggers

| Trigger | When to Use |
|---------|-------------|
| `on viewport` | Below the fold content |
| `on interaction` | Load on click/focus/hover |
| `on idle` | Load when browser is idle |
| `on timer(500ms)` | Load after delay |
| `when condition` | Load when expression is true |

```html
<!-- Multiple triggers -->
@defer (on viewport; on interaction) {
  <comments />
}

<!-- Conditional -->
@defer (when showComments()) {
  <comments />
}
```

---

## Lazy Routes

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
| SEO critical (blog, e-commerce) | SSR |
| Dashboard/Admin | CSR |
| Static marketing site | SSG/Prerender |

---

## Slow Computations

| Solution | When |
|----------|------|
| Optimize algorithm | First choice always |
| Pure pipes | Cache single result |
| Memoization | Cache multiple results |
| `computed()` | Derived signal state |

**NEVER** trigger reflows/repaints in lifecycle hooks (`ngOnInit`, `ngAfterViewInit`).

---

## Resources

- https://angular.dev/guide/image-optimization
- https://angular.dev/guide/defer
- https://angular.dev/best-practices/runtime-performance
- https://angular.dev/guide/ssr
