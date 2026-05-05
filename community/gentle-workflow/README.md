# gentle-workflow

Decision trees for the Gentleman ecosystem — answering **WHEN** to use each tool, not HOW.

## Motivation

Thanks to the outstanding work of [@Gentleman-Programming](https://github.com/Gentleman-Programming),
we now have a brilliant, production-ready ecosystem for building AI-powered development workflows:
**gentle-ai**, **Engram**, **SDD**, the **Skills system**, and **GGA**.

The problem is that knowing *how* each tool works is only half the battle.
The harder question — the one this skill answers — is **when** to activate each one.

When should you trigger SDD? When is it overkill? What deserves a spot in Engram and what's just noise?
When does the orchestrator delegate, and when can it answer inline? Which skill do you load and when?

This skill is a set of five decision trees, one per tool, designed to remove that friction
and let you move with confidence through the ecosystem that Gentleman-Programming built.

## What it covers

| Tree | Question it answers |
|------|-------------------|
| SDD | Should I activate SDD? Which phases do I actually need? |
| Engram | Should I save this? In what format? |
| Orchestrator | Do I answer inline or delegate to a sub-agent? |
| Skills | Which skill do I load right now? |
| GGA | Should GGA review this commit? Which mode? |

## Installation

Copy this folder to your agent's skills directory:

```bash
# Claude Code
cp -r gentle-workflow ~/.claude/skills/

# OpenCode
cp -r gentle-workflow ~/.config/opencode/skills/

# Gemini CLI
cp -r gentle-workflow ~/.gemini/skills/
```

Then load it when you need to make a workflow decision — or add the trigger to your `CLAUDE.md`:

```markdown
| Working with gentle-ai, Engram, SDD, Skills or GGA | Read `~/.claude/skills/gentle-workflow/SKILL.md` |
```
