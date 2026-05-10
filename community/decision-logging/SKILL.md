---
name: decision-logging
description: "Trigger: loguear decisiones, registrar elecciones, guardar log, why did you do X. Log every AI decision with reasoning chain, multi-format export (TXT/Markdown), tamper-proof hash chain."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Activation Contract

Load this skill when:
- You make a decision, choose an approach, or take a path that affects execution
- The user asks "why did you do X" or "what decisions did you make"
- User requests "loguear decisiones", "registrar elecciones", "guardar log de decisiones"
- Building AI agents that need a complete decision audit trail
- Implementing compliance or explainability requirements

## Hard Rules

1. **Log EVERY decision** — any moment where you choose a path (framework, pattern, structure, approach, tool)
2. **Include reasoning** — always write WHY this path was chosen over alternatives
3. **Never log sensitive data** — sanitize context (no passwords, tokens, PII)
4. **Use consistent structure** — always `DecisionEvent` interface with categories
5. **Tamper-proof chain** — each entry MUST include hash of previous entry (prevHash + hash)
6. **Multi-format support** — export to Markdown, JSON Lines, or TXT based on user intent

## Decision Gates

```
User specifies format explicitly?   → Use that format
User asks "documentación"?          → Markdown
User asks "json/estructurado"?      → JSON Lines
User asks "log/txt/simple"?         → TXT
Otherwise                           → JSON Lines (default)
```

## Execution Steps

1. **Detect decision point** — any moment where you choose a path
2. **Build DecisionEvent** — capture: id, timestamp, sessionId, agent, category, input.context, input.alternatives, decision.chosen, decision.reasoning, decision.confidence
3. **Select format** — infer from user intent or use JSON Lines default
4. **Compute hash** — SHA-256 of previous entry hash + current entry (handled by DecisionLogger)
5. **Write to log** — append to `.gentleman/decisions/{sessionId}.jsonl`
6. **On demand export** — call `exportToMarkdown()` or `exportToText()` if requested

## Output Contract

Return:
- Log file path written (.jsonl)
- Chain verification status (OK / BROKEN)
- Exported file paths if export was requested

## References

- `assets/logger.ts` — DecisionLogger implementation with DecisionEvent schema
- `assets/viewer.ts` — CLI export tool (verify + export)