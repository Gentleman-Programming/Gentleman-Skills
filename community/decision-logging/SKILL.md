---
name: decision-logging
description: "Trigger: log decision, audit trail, decision logging. Log AI decisions with immutable chain, reasoning, export to TXT or Markdown."
license: Apache-2.0
metadata:
  author: JoseMRT2004
  version: "1.2"
---

## Activation Contract

Load this skill when:
- Recording a design choice or library selection
- Building an audit trail for auth, data mutation, or critical ops
- User requests a decision log or export to readable format
- Session ends and decision history must persist

## Hard Rules

- DecisionEvent is immutable; never overwrite entries
- Append-only to `.jsonl` with hash chain (prevHash + hash)
- Export to `.txt` and `.md` locally in `.gentleman/decisions/`
- Log full context: alternatives considered, reasoning chain, confidence 0-1
- Never log only the final result — traceback required

## Decision Gates

| Need | Action |
|------|--------|
| Log a decision | `DecisionLogger.log(event)` with full DecisionEvent |
| Export session | `exportToText()` or `exportToMarkdown()` |
| Verify chain integrity | `DecisionLogger.verifyChain(filePath)` |

## Execution Steps

1. Import `DecisionLogger` from `assets/logger.ts`
2. Initialize: `const logger = new DecisionLogger(sessionId)`
3. At decision point: `await logger.log({ id, sessionId, timestamp, agent, category, input, decision })`
4. On session end (if export requested): `await logger.exportToMarkdown(sessionId)`

## Output Contract

Return: files created/modified, chain verification status (OK / BROKEN), exported file paths.

## References

- `assets/logger.ts` — DecisionLogger implementation with full DecisionEvent schema and categories
- `assets/viewer.ts` — CLI export tool (verify + export)