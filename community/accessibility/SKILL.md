---
name: accessibility
description: >
  Web accessibility (a11y) patterns and WCAG 2.2 compliance.
  Trigger: When building accessible components, when adding ARIA attributes, when ensuring WCAG compliance.
metadata:
  author: dsantiagomj
  version: "1.0"
---

## When to Use

- Building UI components that need keyboard navigation
- Adding ARIA attributes to interactive elements
- Ensuring WCAG 2.2 AA compliance
- Creating accessible forms with proper labels
- Implementing focus management in modals/dialogs
- Testing accessibility with screen readers
- Checking color contrast and visual requirements
- Writing alt text for images

---

## Semantic HTML (REQUIRED)

```tsx
// ✅ ALWAYS: Use semantic HTML elements
<header>
  <nav>
    <a href="/">Home</a>
    <a href="/about">About</a>
  </nav>
</header>
<main>
  <article>
    <h1>Article Title</h1>
    <p>Content here...</p>
  </article>
</main>

// ❌ NEVER: Divs for everything
<div className="header">
  <div className="nav">
    <div onClick={navigate}>Home</div>
  </div>
</div>
<div className="main">
  <div className="title">Article Title</div>
</div>
```

**Why?** Screen readers understand structure, keyboard navigation works automatically, better SEO.

---

## Keyboard Navigation (REQUIRED)

```tsx
// ✅ ALWAYS: Use native buttons
<button onClick={handleClick}>Click me</button>

// ❌ NEVER: Non-focusable elements with onClick
<div onClick={handleClick}>Click me</div>

// ✅ If you must use div, add keyboard support
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  Click me
</div>
```

**tabIndex rules:**
- `0` = Include in natural tab order
- `-1` = Programmatically focusable only
- Never use positive numbers (disrupts natural order)

---

## Form Labels (REQUIRED)

```tsx
// ✅ ALWAYS: Explicit labels
<label htmlFor="email">Email address *</label>
<input
  id="email"
  type="email"
  aria-required="true"
  aria-invalid={hasError}
  aria-describedby={hasError ? "email-error" : undefined}
/>
{hasError && (
  <div id="email-error" role="alert">
    Please enter a valid email address
  </div>
)}

// ❌ NEVER: Placeholder as label
<input type="email" placeholder="Email" />
```

---

## ARIA When Needed

```tsx
// ✅ Icon buttons need aria-label
<button aria-label="Close dialog">
  <X />
</button>

// ✅ Modal dialogs
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
>
  <h2 id="dialog-title">Confirm Delete</h2>
  <p>Are you sure?</p>
</div>

// ✅ Live regions for dynamic content
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

// ✅ Expandable sections
<button
  aria-expanded={isOpen}
  aria-controls="content"
  onClick={() => setIsOpen(!isOpen)}
>
  Toggle Section
</button>
<div id="content" hidden={!isOpen}>
  Content here
</div>
```

**Common ARIA attributes:**
- `aria-label` - Provide text label for icon buttons
- `aria-labelledby` - Reference existing element as label
- `aria-describedby` - Additional description (form hints)
- `aria-hidden="true"` - Hide decorative elements from screen readers
- `aria-live` - Announce dynamic content (`polite` or `assertive`)
- `aria-required` - Mark required form fields
- `aria-invalid` - Mark invalid form fields

---

## Focus Management (REQUIRED)

```tsx
// ✅ Modal focus trap
function Modal({ isOpen, onClose, children }) {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousFocus = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (isOpen) {
      previousFocus.current = document.activeElement as HTMLElement;
      modalRef.current?.focus();

      const handleKeyDown = (e: KeyboardEvent) => {
        if (e.key === 'Escape') onClose();
      };

      document.addEventListener('keydown', handleKeyDown);
      return () => document.removeEventListener('keydown', handleKeyDown);
    } else {
      previousFocus.current?.focus();
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}
    >
      <button onClick={onClose} aria-label="Close">×</button>
      {children}
    </div>
  );
}
```

```css
/* ✅ ALWAYS: Visible focus indicators */
button:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* ❌ NEVER: Remove outline without replacement */
button:focus {
  outline: none; /* DON'T DO THIS */
}
```

---

## Color Contrast (REQUIRED)

**WCAG 2.2 AA Requirements:**
- Normal text: **4.5:1** contrast ratio
- Large text (18pt+ or 14pt+ bold): **3:1** contrast ratio
- UI components (buttons, borders): **3:1** contrast ratio

```css
/* ❌ Fails AA - insufficient contrast */
.text {
  color: #777777; /* 4.3:1 against white */
  background: #ffffff;
}

/* ✅ Passes AA */
.text {
  color: #595959; /* 7:1 against white */
  background: #ffffff;
}
```

**Tools:** [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/), Chrome DevTools

---

## Image Alt Text

```tsx
// ✅ Descriptive alt text
<img src="chart.png" alt="Bar chart showing 25% sales increase in Q4" />

// ✅ Decorative images - empty alt
<img src="decorative.png" alt="" />

// ✅ Icon with text - hide icon from screen readers
<button>
  <img src="save.png" alt="" aria-hidden="true" />
  Save
</button>

// ❌ Missing alt
<img src="photo.png" />

// ❌ Redundant alt
<img src="photo.png" alt="Image of photo" />
```

---

## Heading Hierarchy

```tsx
// ✅ Logical heading order
<h1>Page Title</h1>
  <h2>Section 1</h2>
    <h3>Subsection 1.1</h3>
    <h3>Subsection 1.2</h3>
  <h2>Section 2</h2>
    <h3>Subsection 2.1</h3>

// ❌ Skipping levels
<h1>Page Title</h1>
  <h3>Should be h2</h3>
  <h5>Skipped h2, h3, h4</h5>
```

---

## Skip Links

```tsx
// ✅ Allow keyboard users to skip navigation
<a href="#main-content" className="skip-link">
  Skip to main content
</a>

<header>
  {/* Navigation */}
</header>

<main id="main-content" tabIndex={-1}>
  {/* Main content */}
</main>
```

```css
/* Show only on focus */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
```

---

## Screen Reader Announcements

```typescript
// ✅ Announce dynamic actions
function useAnnounce() {
  return (message: string, priority: 'polite' | 'assertive' = 'polite') => {
    const announcement = document.createElement('div');
    announcement.setAttribute('role', 'status');
    announcement.setAttribute('aria-live', priority);
    announcement.setAttribute('aria-atomic', 'true');
    announcement.className = 'sr-only';
    announcement.textContent = message;

    document.body.appendChild(announcement);
    setTimeout(() => document.body.removeChild(announcement), 1000);
  };
}

// Usage
function AddToCart({ product }) {
  const announce = useAnnounce();

  const handleAdd = () => {
    addToCart(product);
    announce(`${product.name} added to cart`);
  };

  return <button onClick={handleAdd}>Add to Cart</button>;
}
```

```css
/* Screen reader only class */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

---

## Testing Checklist

**Manual Testing:**
- [ ] Tab through entire page (keyboard navigation)
- [ ] Use screen reader (VoiceOver on Mac, NVDA on Windows)
- [ ] Test at 200% zoom
- [ ] Check color contrast with tools

**Automated Tools:**
- axe DevTools (browser extension)
- Lighthouse (Chrome DevTools)
- ESLint: `eslint-plugin-jsx-a11y`

**Minimum Requirements (WCAG AA):**
- [ ] 4.5:1 text contrast (3:1 for large text)
- [ ] All functionality keyboard accessible
- [ ] Visible focus indicators
- [ ] All form inputs labeled
- [ ] Meaningful alt text for images
- [ ] Logical heading structure
- [ ] Error messages clear and announced

---

## Quick Reference

| Pattern | Code |
|---------|------|
| Icon button | `<button aria-label="Close">×</button>` |
| Required input | `<input aria-required="true" required />` |
| Error message | `<div role="alert">{error}</div>` |
| Modal | `<div role="dialog" aria-modal="true">` |
| Live region | `<div aria-live="polite">{status}</div>` |
| Skip link | `<a href="#main">Skip to content</a>` |

## Resources

- [WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

## Keywords
accessibility, a11y, wcag, aria, keyboard navigation, screen readers, semantic html, focus management
