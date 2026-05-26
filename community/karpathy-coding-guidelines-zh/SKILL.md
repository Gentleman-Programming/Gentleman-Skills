---
name: karpathy-coding-guidelines-zh
description: >
  Apply Chinese AI coding-agent rules inspired by Andrej Karpathy's guidance:
  think before coding, keep changes simple, scope diffs precisely, and verify.
  Trigger: When using Claude Code, Codex, Cursor, or other coding agents in
  Chinese-language projects or teams that need safer coding behavior.
metadata:
  author: MackDing
  version: "1.0"
---

## When to Use

Use this skill when an AI coding agent needs clearer engineering behavior rules:

- The user is working in Chinese and wants project-level coding-agent guidelines.
- A task risks over-engineering, unrelated refactors, hidden assumptions, or unverifiable changes.
- A project needs reusable `CLAUDE.md`, `AGENTS.md`, Cursor Rules, or skill-style instructions.
- A reviewer wants the agent to keep diffs small and explain tradeoffs before editing.

Canonical source: <https://github.com/MackDing/andrej-karpathy-skills-zh>

## Critical Patterns

### Think Before Coding

State assumptions, ambiguity, and tradeoffs before changing files. If the requirement is unclear, ask before inventing scope.

```markdown
## Before Editing

- Goal: Fix the login timeout error.
- Assumption: The timeout comes from the API client retry loop, not the UI.
- Risk: Changing global fetch behavior may affect unrelated requests.
- Plan: Add a narrow timeout override only for login and verify with the existing auth tests.
```

### Keep The Smallest Working Diff

Prefer the smallest change that solves the problem. Do not add abstractions, new packages, or broad rewrites unless the local codebase already points there.

```diff
- replace the entire auth module
+ add a bounded retry option to the existing login request
+ add one regression test for timeout behavior
```

### Verify Before Claiming Completion

The agent must run the relevant checks or clearly state what could not be run. A claim without verification is not finished work.

```bash
npm test -- auth-timeout.test.ts
npm run lint
git diff --check
```

## Code Examples

### Example 1: Codex `AGENTS.md` Rule

```markdown
Before editing, identify the smallest module that owns the behavior.
Do not refactor unrelated files. After editing, run the narrowest relevant test
and report the command and result.
```

### Example 2: Claude Code `CLAUDE.md` Rule

```markdown
When requirements are ambiguous, stop and expose the ambiguity in Chinese.
List at most three interpretations and recommend the safest default.
Only proceed without asking when one option is clearly implied by existing code.
```

### Example 3: Cursor Rule

```markdown
---
description: Keep AI coding changes scoped and verifiable
globs: ["**/*"]
alwaysApply: true
---

Prefer precise diffs. Do not introduce new architecture for a local bug fix.
Use existing helpers and tests before adding new patterns.
```

## Anti-Patterns

### Don't: Hide Assumptions

```text
Bad: "I'll update the auth flow" while silently changing routing and session storage.
Good: "I am assuming the timeout is login-specific; I will only edit the login request."
```

### Don't: Turn A Bug Fix Into A Rewrite

```text
Bad: Replace the data layer, rename files, and migrate unrelated code.
Good: Patch the failing branch and add one focused regression test.
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Ambiguous request | `assumptions -> options -> safest recommendation` |
| Bug fix | `smallest owner -> focused patch -> regression test` |
| Completion | `commands run -> result -> residual risk` |

## Resources

- Source repository: <https://github.com/MackDing/andrej-karpathy-skills-zh>
