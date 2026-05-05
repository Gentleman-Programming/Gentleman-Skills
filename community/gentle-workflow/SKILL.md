---
name: gentle-workflow
description: >
  Decision trees for the Gentleman ecosystem (gentle-ai, Engram, SDD, Skills, GGA).
  Trigger: When working with gentle-ai, Engram, SDD workflows, the Gentleman Skills system,
  or GGA code reviews — and needing to decide WHEN to activate each tool, not how to use it.
metadata:
  author: Gentleman-Programming
  version: "1.0"
---

# gentle-workflow

> Decision trees for the [Gentleman ecosystem](https://github.com/Gentleman-Programming).
> This skill answers **WHEN** to use each tool — not HOW.
> For HOW, each tool has its own documentation.

---

## When to Use

Load this skill when any of these conditions are true:

- You are about to start a new task and need to decide if SDD is warranted
- You just completed significant work and are unsure whether to save it to Engram
- You are an orchestrator deciding whether to answer inline or delegate to a sub-agent
- You detect a framework/technology in the project and need to pick the right skill to load
- You are about to commit code and need to decide if GGA should review it

---

## SDD Decision Tree

SDD (Spec-Driven Development) adds planning overhead. Only use it when the complexity justifies the cost.

### Should I activate SDD?

| Condition | Action |
|-----------|--------|
| Bug fix (root cause is known) | ❌ Skip SDD → direct `apply` |
| Task touches 1 file, < 30 min | ❌ Skip SDD → inline |
| Task touches 2+ files with logic dependencies | ✅ Minimum SDD |
| New feature with architecture decisions | ✅ Full SDD |
| Refactor affecting multiple layers or contracts | ✅ Full SDD |
| Unclear requirements or unknowns | ✅ Start with `sdd-explore` first |

### Which SDD phases to run?

```
Full DAG:  explore → propose → spec + design → tasks → apply → verify → archive
```

| Task size | Phases to run | Phases to skip |
|-----------|--------------|----------------|
| Bug fix | `apply` only | Everything else |
| Small feature (1–2 files, clear requirements) | `explore → tasks → apply` | propose, design, verify, archive |
| Medium feature (clear requirements, known patterns) | `explore → propose → tasks → apply → verify` | design (if no new patterns) |
| Large feature / new architecture | Full DAG | Nothing |
| Unclear requirements | Start with `explore` only, then decide | Everything else until explored |

### Anti-pattern: SDD for everything

```
// DON'T — overkill for trivial work
sdd-new "fix typo in README"

// DO — just fix it directly
edit README.md → commit
```

---

## Engram Decision Tree

Engram is long-term memory. Polluting it with noise destroys its value. Save precisely.

### Should I save to Engram right now?

| Condition | Action |
|-----------|--------|
| Architectural decision made | ✅ Save now — `type: decision` |
| Bug fixed AND root cause understood | ✅ Save now — `type: bugfix` |
| Pattern or convention established | ✅ Save now — `type: pattern` |
| Non-obvious discovery or gotcha found | ✅ Save now — `type: discovery` |
| User preference or workflow constraint learned | ✅ Save now — `type: preference` |
| Currently working on something in progress | ❌ Skip — save when done |
| Info already documented in CLAUDE.md | ❌ Skip — avoid duplication |
| Speculative / unverified conclusion | ❌ Skip — verify first |
| Session-specific detail (what I'm doing right now) | ❌ Skip — this is noise |

### What to save (required format)

Every observation must answer these four questions:

```markdown
**What**: One sentence — what was done or decided
**Why**: The motivation (bug, user request, performance, architecture)
**Where**: Files or paths affected
**Learned**: Gotchas, edge cases, non-obvious decisions (omit if none)
```

### Session lifecycle — mandatory

```
Start of session  → call mem_context (recover prior context)
End of session    → call mem_session_summary (Goal / Discoveries / Accomplished / Next Steps / Files)
After compaction  → IMMEDIATELY call mem_session_summary, then mem_context
```

### Topic key discipline

Same topic updated over time → use the same `topic_key` (upsert, not duplicate).

```
architecture/auth-model    → authentication decisions
sdd/{change-name}/design   → SDD artifacts
session/{project}-context  → running session context
```

---

## Orchestrator Decision Tree

The orchestrator coordinates — it never executes. No exceptions.

### Should I answer inline or delegate?

| Action type | Decision |
|-------------|----------|
| Simple factual question (no code read/write required) | ✅ Answer inline |
| Question answerable in < 3 sentences from memory | ✅ Answer inline |
| Reading source code to "understand" the codebase | ❌ Delegate |
| Writing or editing any file | ❌ Delegate |
| Analysis of 2+ files | ❌ Delegate |
| Writing specs, proposals, designs, or task breakdowns | ❌ Delegate |
| "It's just a small change" in 1 file | ❌ Delegate — no size exceptions |
| Running tests or build commands | ❌ Delegate |

### Delegation mode: async first

```
Default: delegate (background, non-blocking)
Exception: task (blocking) — only when you NEED the result before your next step
```

### Anti-pattern: the inline shortcut

```
// DON'T — orchestrator writing code directly
"Let me just make this small change to fix the import..."
Edit: src/app.ts

// DO — always delegate
Launch sub-agent: "Fix the import in src/app.ts. Follow existing patterns."
```

### Sub-agent context protocol

Sub-agents start with zero memory. The orchestrator is responsible for:

1. Searching Engram for relevant prior context (`mem_search`)
2. Passing context in the sub-agent prompt
3. Instructing the sub-agent to save discoveries to Engram before returning

---

## Skills Decision Tree

Skills auto-load when triggers match. This tree is a manual decision aid when auto-detection doesn't fire.

### Which skill should I load?

| You are working with | Load skill |
|---------------------|-----------|
| React components, hooks, context | `react-19` |
| Angular components, services, signals | `angular` |
| TypeScript types, generics, strict mode | `typescript` |
| Next.js pages, App Router, Server Actions | `nextjs-15` |
| Tailwind CSS classes, utilities, variants | `tailwind-4` |
| Zod schemas, validation, inference | `zod-4` |
| Zustand stores, slices, devtools | `zustand-5` |
| Vercel AI SDK, streaming, tool calls | `ai-sdk-5` |
| Django REST API, serializers, viewsets | `django-drf` |
| Playwright E2E tests, locators, fixtures | `playwright` |
| pytest tests, fixtures, parametrize | `pytest` |
| GitHub PR title, description, review | `github-pr` |
| Jira task creation or updates | `jira-task` |
| Jira epic creation or planning | `jira-epic` |
| Creating a new skill for any agent | `skill-creator` |

### Multiple skills can apply simultaneously

```
Working on a Next.js page with Zod form validation:
→ Load: nextjs-15 + zod-4 + typescript
```

### When NOT to load a skill

- No matching framework or technology detected → proceed with general conventions
- Already loaded this session and context hasn't changed → skip reload

---

## GGA Decision Tree

GGA reviews code against your standards on every commit. Use it selectively to avoid false positives.

### Should I activate GGA?

| Condition | Action |
|-----------|--------|
| Committing production-ready code | ✅ GGA active |
| PR before merge on a team project | ✅ GGA PR mode |
| Enforcing consistent coding standards | ✅ GGA active |
| Prototyping / experimental branch | ❌ Skip — standards don't apply yet |
| WIP commit (will be squashed) | ❌ Skip — premature review |
| Documentation-only change (`.md`, comments) | ❌ Skip — no logic to review |
| Already running GGA in CI/CD pipeline | ❌ Skip local hook — avoid double review |
| Trivial change (rename, format, import order) | ⚠️ Optional — use judgement |

### Which mode?

| Scenario | Mode |
|----------|------|
| Pre-commit hook (default) | `gga install` → auto-runs on `git commit` |
| Full PR review before merge | `gga review` (PR mode) |
| CI/CD integration | Pipeline mode — see GGA docs |
| Changing the AI provider | Update config only — no reinstall needed |

### Anti-pattern: GGA blocking fast iteration

```
// DON'T — GGA on every WIP commit during active development
git commit -m "wip: trying something"
# GGA fires → slow → frustrating → you disable it entirely

// DO — skip on WIP, enforce on real commits
git commit -m "wip: trying something" --no-verify   # WIP only
git commit -m "feat: add user auth"                 # GGA reviews this
```

---

## Anti-Patterns

### 1. SDD for every task

Using SDD on bug fixes and trivial changes adds overhead with zero benefit. Reserve SDD for tasks with genuine architectural complexity or 3+ file dependencies.

### 2. Saving noise to Engram

Saving "what I'm currently working on" or in-progress state pollutes memory. Engram is long-term signal — only save completed decisions, fixed bugs, established patterns.

### 3. Orchestrator writing code directly

"It's just a small change" is the most dangerous phrase in agent orchestration. Every inline code edit by the orchestrator blooms context, accelerates compaction, and causes state loss. No size exceptions.

### 4. Not loading skills before writing framework code

Writing React without `react-19`, Angular without `angular`, or TypeScript without `typescript` loaded produces generic patterns that violate project conventions. Load first, write second.

### 5. GGA on WIP commits

Running GGA on work-in-progress creates false positives that erode trust in the tool. The result: developers disable GGA entirely. Reserve it for commits that represent real, shippable work.

---

## Quick Reference

| Tool | Activate when | Skip when |
|------|--------------|-----------|
| **SDD** | 3+ files, arch decisions, unclear requirements | Bug fixes, single-file tasks, < 30 min |
| **Engram** | Decision made, bug fixed, pattern found, session ends | WIP, session temp state, already in CLAUDE.md |
| **Orchestrator** | Any code read/write/analysis | Simple Q&A answerable from memory |
| **Skills** | Matching framework/technology detected | No framework match, already loaded |
| **GGA** | Production commit, PR review, team standards | WIP, prototyping, docs-only, already in CI/CD |

---

## Resources

- [Gentleman-Programming GitHub](https://github.com/Gentleman-Programming) — ecosystem source
- [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) — ecosystem configurator (install once)
- [engram](https://github.com/Gentleman-Programming/engram) — persistent memory system
- [Gentleman-Skills](https://github.com/Gentleman-Programming/Gentleman-Skills) — skills library
- [GGA](https://github.com/Gentleman-Programming/gentleman-guardian-angel) — code review tool
- [agent-teams-lite](https://github.com/Gentleman-Programming/agent-teams-lite) — archived SDD reference
