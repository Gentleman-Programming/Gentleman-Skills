---
name: angular-core
description: >
  Angular core patterns: standalone components, signals, inject, control flow, zoneless.
  Trigger: When creating Angular components, using signals, or setting up zoneless.
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Standalone Components (REQUIRED)

Components are standalone by default. Do NOT set `standalone: true`.

```typescript
@Component({
  selector: 'app-user',
  imports: [CommonModule],
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

// Update
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

```html
@if (loading()) {
  <spinner />
} @else {
  @for (item of items(); track item.id) {
    <item-card [data]="item" />
  } @empty {
    <p>No items</p>
  }
}

@switch (status()) {
  @case ('active') { <span>Active</span> }
  @default { <span>Unknown</span> }
}
```

---

## Zoneless Angular (REQUIRED)

Angular is zoneless. Use `provideZonelessChangeDetection()`.

```typescript
bootstrapApplication(AppComponent, {
  providers: [provideZonelessChangeDetection()]
});
```

Remove ZoneJS:
```bash
npm uninstall zone.js
```

Remove from `angular.json` polyfills: `zone.js` and `zone.js/testing`.

### Zoneless Requirements
- Use `OnPush` change detection
- Use signals for state (auto-notifies Angular)
- Use `AsyncPipe` for observables
- Use `markForCheck()` when needed

---

## Resources

- https://angular.dev/guide/signals
- https://angular.dev/guide/templates/control-flow
- https://angular.dev/guide/zoneless
