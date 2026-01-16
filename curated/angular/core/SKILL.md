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

## NO Lifecycle Hooks (REQUIRED)

Signals replace lifecycle hooks. Do NOT use `ngOnInit`, `ngOnChanges`, `ngOnDestroy`.

```typescript
// ❌ NEVER: Lifecycle hooks
ngOnInit() {
  this.loadUser();
}

ngOnChanges(changes: SimpleChanges) {
  if (changes['userId']) {
    this.loadUser();
  }
}

// ✅ ALWAYS: Signals + effect
readonly userId = input.required<string>();
readonly user = signal<User | null>(null);

private userEffect = effect(() => {
  // Runs automatically when userId() changes
  this.loadUser(this.userId());
});

// ✅ For derived data, use computed
readonly displayName = computed(() => this.user()?.name ?? 'Guest');
```

### When to Use What

| Need | Use |
|------|-----|
| React to input changes | `effect()` watching the input signal |
| Derived/computed state | `computed()` |
| Side effects (API calls, localStorage) | `effect()` |
| Cleanup on destroy | `DestroyRef` + `inject()` |

```typescript
// Cleanup example
private readonly destroyRef = inject(DestroyRef);

constructor() {
  const subscription = someObservable$.subscribe();
  this.destroyRef.onDestroy(() => subscription.unsubscribe());
}
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

## RxJS - Only When Needed

Signals are the default. Use RxJS ONLY for complex async operations.

| Use Signals | Use RxJS |
|-------------|----------|
| Component state | Combining multiple streams |
| Derived values | Debounce/throttle |
| Simple async (single API call) | Race conditions |
| Input/Output | WebSockets, real-time |
| | Complex error retry logic |

```typescript
// ✅ Simple API call - use signals
readonly user = signal<User | null>(null);
readonly loading = signal(false);

async loadUser(id: string) {
  this.loading.set(true);
  this.user.set(await firstValueFrom(this.http.get<User>(`/api/users/${id}`)));
  this.loading.set(false);
}

// ✅ Complex stream - use RxJS
readonly searchResults$ = this.searchTerm$.pipe(
  debounceTime(300),
  distinctUntilChanged(),
  switchMap(term => this.http.get<Results>(`/api/search?q=${term}`))
);

// Convert to signal when needed in template
readonly searchResults = toSignal(this.searchResults$, { initialValue: [] });
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
