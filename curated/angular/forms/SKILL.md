---
name: angular-forms
description: >
  Angular forms: Signal Forms (experimental) and Reactive Forms.
  Trigger: When working with forms, validation, or form state in Angular.
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use What

| Use Case | Recommendation |
|----------|----------------|
| New apps with signals | Signal Forms (experimental) |
| Production apps | Reactive Forms |
| Simple forms | Template-driven |

---

## Signal Forms (v21+, experimental)

```typescript
import { form, FormField, required, email } from '@angular/forms/signals';

@Component({
  imports: [FormField],
  template: `
    <form>
      <input [formField]="emailField" type="email" />
      <input [formField]="passwordField" type="password" />
      <button (click)="submit()">Login</button>
    </form>
  `
})
export class LoginComponent {
  readonly loginForm = form({
    email: ['', [required, email]],
    password: ['', required]
  });
  
  readonly emailField = this.loginForm.controls.email;
  readonly passwordField = this.loginForm.controls.password;
  
  submit() {
    if (this.loginForm.valid()) {
      const values = this.loginForm.value();
    }
  }
}
```

### Signal Forms Benefits
- Automatic two-way binding
- Type-safe field access
- Schema-based validation
- Built on signals

---

## Reactive Forms (production)

```typescript
import { FormBuilder, Validators, ReactiveFormsModule } from '@angular/forms';

@Component({
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="submit()">
      <input formControlName="email" type="email" />
      <input formControlName="password" type="password" />
      <button type="submit" [disabled]="form.invalid">Login</button>
    </form>
  `
})
export class LoginComponent {
  private readonly fb = inject(FormBuilder);

  form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
  });
  
  submit() {
    if (this.form.valid) {
      const { email, password } = this.form.getRawValue();
    }
  }
}
```

### Key Points
- ALWAYS use `fb.nonNullable.group()` for type safety
- Use `getRawValue()` to get typed values
- Reactive Forms are synchronous (easier to test)

---

## Nested Forms & FormArray

```typescript
form = this.fb.nonNullable.group({
  name: [''],
  address: this.fb.group({
    street: [''],
    city: [''],
  }),
  phones: this.fb.array([this.fb.control('')]),
});

get phones() {
  return this.form.get('phones') as FormArray;
}

addPhone() {
  this.phones.push(this.fb.control(''));
}
```

---

## Resources

- https://angular.dev/guide/forms/signals/overview
- https://angular.dev/guide/forms/reactive-forms
