# decision-logging

## What it does
Provides a structured logging system for AI agent decisions, capturing the full reasoning chain, timestamp, and context. **Exports logs to TXT and Markdown** locally.

## Why it matters
- Auditability: trace every decision back to its rationale.
- Debugging: replay decision sequences to find bugs.
- Memory: persist context across sessions.
- Readability: export to human-friendly formats for sharing or review.

## Structure
- `SKILL.md` – main agent instructions.
- `examples/` – reference implementations (logger, viewer with export).
- `.gentleman/decisions/` – local storage folder for `.jsonl` (immutable), `.txt` and `.md` (exports).

## Quick start
1. Copy this folder to your agent's skills directory.
2. Reference it in your agent configuration (e.g., `CLAUDE.md`):
   ```
   When making decisions, load `~/.claude/skills/decision-logging/SKILL.md`.
   ```
3. Use the logger in your code:
   ```ts
   const logger = new DecisionLogger('my-session');
   await logger.log({ ... });
   await logger.exportToText('my-session');
   ```
4. Or run the viewer to export existing logs:
   ```bash
   npx ts-node examples/viewer.ts my-session
   ```

## Author
Created by [JoseMRT2004](https://github.com/JoseMRT2004). Licensed under MIT.
