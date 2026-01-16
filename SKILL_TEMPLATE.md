# Skill Template

Use this template when creating a new skill. Copy this file to your skill folder and rename it to `SKILL.md`.

**Important**: The YAML frontmatter at the top is REQUIRED and will be validated automatically.

---

```markdown
---
name: your-skill-name
description: >
  Brief description of what this skill covers.
  Trigger: When working with [technology], when building [type of app], when using [library].
metadata:
  author: your-github-username
  version: "1.0"
---

## When to Use

Load this skill when:
- [Condition 1, e.g., "Working with React Native components"]
- [Condition 2, e.g., "Building mobile apps with Expo"]
- [Condition 3, e.g., "Using React Navigation"]

## Critical Patterns

### Pattern 1: [Name]

[Explanation of the pattern]

```typescript
// Good example
const example = () => {
  // Your code here
};
```

### Pattern 2: [Name]

[Explanation of the pattern]

```typescript
// Good example
const example = () => {
  // Your code here
};
```

### Pattern 3: [Name]

[Explanation of the pattern]

```typescript
// Good example
const example = () => {
  // Your code here
};
```

## Code Examples

### Example 1: [Use Case]

```typescript
// Complete example showing the pattern in action
const completeExample = () => {
  // Implementation
};
```

### Example 2: [Use Case]

```typescript
// Another example
const anotherExample = () => {
  // Implementation
};
```

### Example 3: [Use Case]

```typescript
// Third example
const thirdExample = () => {
  // Implementation
};
```

## Anti-Patterns

### Don't: [Anti-pattern name]

[Why this is bad]

```typescript
// Bad example - DON'T do this
const badExample = () => {
  // What NOT to do
};
```

### Don't: [Anti-pattern name]

[Why this is bad]

```typescript
// Bad example - DON'T do this
const badExample = () => {
  // What NOT to do
};
```

## Quick Reference

| Task | Pattern |
|------|---------|
| [Task 1] | `code snippet` |
| [Task 2] | `code snippet` |
| [Task 3] | `code snippet` |

## Resources

- [Official Documentation](https://example.com)
- [Migration Guide](https://example.com/migration)
```

---

## Validation Checklist

Before submitting, ensure your skill passes these checks:

### Frontmatter (REQUIRED)
- [ ] Starts with `---`
- [ ] Has `name:` field (lowercase, hyphens only)
- [ ] Has `description:` field with "Trigger:" included
- [ ] Has `metadata:` with `author:` and `version:`
- [ ] Ends with `---`

### Required Sections
- [ ] Has `## When to Use` or `## Trigger` section
- [ ] Has `## Critical Patterns` or `## Core Patterns` section
- [ ] Has `## Code Examples` section

### Code Examples
- [ ] At least 3 code blocks (recommended)
- [ ] Examples are complete and runnable
- [ ] Shows both good patterns and anti-patterns

### Commits
- [ ] All commits follow conventional commits format
- [ ] Example: `feat(community): add your-skill-name skill`
