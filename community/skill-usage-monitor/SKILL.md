---
name: skill-usage-monitor
description: >
  Monitor and analyze AI agent skill calls with the Skill Usage dashboard for
  OpenClaw, Hermes-Agent, Claude Code, Codex, and JSONL-based agents.
  Trigger: When diagnosing redundant skills, slow skills, failed skill calls,
  or unclear skill usage across agent sessions.
metadata:
  author: MackDing
  version: "1.0"
---

## When to Use

Use this skill when the user wants operational visibility into skills:

- Find which skills are called most often and whether they are useful.
- Detect slow, failing, idle, or redundant skills.
- Monitor Codex, Claude Code, OpenClaw, Hermes-Agent, or any JSONL-based session logs.
- Prepare before pruning or reorganizing a large skill library.
- Demo skill usage behavior in a lightweight local dashboard.

Canonical source: <https://github.com/MackDing/skill-usage>

## Critical Patterns

### Start With A Read-Only Watch

Point the dashboard at a copy or read-only session directory first. Do not mutate agent logs while analyzing usage.

```bash
git clone https://github.com/MackDing/skill-usage.git
cd skill-usage
node src/server.mjs --watch ./sessions
```

### Compare Frequency With Failure Rate

High call volume is not always good. Prioritize skills that are frequent and failing, slow, or idle after install.

```text
Review order:
1. Failed calls by skill
2. P95 latency by skill
3. High-frequency skills with low completion value
4. Skills installed but never triggered
```

### Keep Monitoring Lightweight

Use the zero-dependency server and JSONL persistence. Avoid adding a database or complex telemetry pipeline until the questions require it.

```bash
node src/server.mjs --watch ~/.codex/sessions
# Open http://localhost:3456
```

## Code Examples

### Example 1: Monitor A Codex Session Folder

```bash
node src/server.mjs --watch ~/.codex/sessions
```

### Example 2: Monitor A Project-Local Log Folder

```bash
node src/server.mjs --watch ./logs/agent-sessions
```

### Example 3: Use Demo Data For A Review

```bash
node src/server.mjs --demo
```

## Anti-Patterns

### Don't: Prune Skills From Raw Frequency Alone

```text
Bad: Delete every low-frequency skill.
Good: Check whether the skill is specialized, recently added, or critical for rare high-value tasks.
```

### Don't: Treat Browser Success As Agent Success

```text
Bad: Assume a dashboard showing events means all skills are working.
Good: Inspect failures, latency, session paths, and whether expected JSONL events are actually parsed.
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Find bad skills | `failure rate -> latency -> useless frequency` |
| Start monitoring | `node src/server.mjs --watch <session-dir>` |
| Reduce risk | `read-only copy -> inspect -> prune intentionally` |

## Resources

- Source repository: <https://github.com/MackDing/skill-usage>
