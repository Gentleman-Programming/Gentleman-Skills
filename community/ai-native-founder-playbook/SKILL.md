---
name: ai-native-founder-playbook
description: >
  Apply a bilingual AI-native startup operating playbook for founder strategy,
  MVP scoping, launch operations, GTM planning, and PMF diagnostics.
  Trigger: When evaluating startup ideas, planning an MVP, designing founder
  workflows, or converting startup strategy into agent-executable work.
metadata:
  author: MackDing
  version: "1.0"
---

## When to Use

Use this skill when the user needs practical startup operating help rather than generic advice:

- Validate an AI-native startup idea before building.
- Convert founder intuition into explicit assumptions, tests, and stage gates.
- Scope an MVP so coding agents do not build a broad platform too early.
- Diagnose PMF, launch operations, GTM motion, founder bottlenecks, or data flywheels.
- Prepare agent workflows for research, coding, publishing, review, and metrics loops.

Canonical source: <https://github.com/MackDing/ai-native-founder-playbook-skill>

## Critical Patterns

### Separate Facts, Assumptions, And Tests

Do not let the agent turn founder excitement into certainty. Split the plan into what is known, what is assumed, and what would prove or disprove the assumption.

```markdown
## Startup Hypothesis

- Fact: The founder has access to 30 target users in the niche.
- Assumption: These users lose more than 3 hours per week on the workflow.
- Risk: The pain may be inconvenient but not budget-worthy.
- Test: Interview 10 users and ask for recent examples, current workaround, and willingness to pre-order.
- Kill criterion: Fewer than 3 users describe a recent high-cost failure.
```

### Stage-Gate Before Build Scope

Always identify whether the company is in idea, MVP, launch, or scale mode before recommending work. The same feature can be useful at scale and wasteful at idea stage.

```markdown
## Stage Gate

Stage: MVP
Goal: Prove one repeated workflow can be completed faster with the product.
Do now: Build one high-frequency path with manual review.
Defer: Marketplace, team roles, generic workflow builder, broad integrations.
Exit criterion: 5 users complete the workflow twice without founder handholding.
```

### Convert Strategy Into Agent Workflows

End with concrete work packets a founder can delegate to research, coding, automation, or review agents.

```markdown
## Agent Work Packets

1. Research agent: collect 20 recent examples of the user's current workaround.
2. Coding agent: implement only the single ingest -> transform -> review path.
3. Automation agent: publish usage events to a weekly PMF dashboard.
4. Human review: inspect failed cases before expanding scope.
```

## Code Examples

### Example 1: MVP Scope Prompt

```text
Use ai-native-founder-playbook to convert this idea into a wedge-first MVP.
Return: stage, riskiest assumptions, excluded features, 2-week build scope,
and 5 exit criteria. Do not propose a platform unless the evidence requires it.
```

### Example 2: PMF Diagnostic Prompt

```text
Use ai-native-founder-playbook to diagnose PMF from these interviews and metrics.
Separate retention, urgency, willingness to pay, switching cost, and founder bias.
List the strongest disconfirming evidence first.
```

### Example 3: Agent Workflow Prompt

```text
Use ai-native-founder-playbook to split this launch plan into agent work packets:
research, coding, content, publishing, data reflow, and weekly review.
Each packet needs inputs, outputs, owner, and verification.
```

## Anti-Patterns

### Don't: Build A Broad Platform From A Vague Problem

Avoid turning an early idea into a large product surface before a specific workflow and buyer pain are verified.

```text
Bad: Build dashboards, integrations, user roles, API, templates, and marketplace.
Good: Build one workflow for one user type and verify repeated use.
```

### Don't: Hide Missing Evidence

If the founder has no interviews, no usage data, or no buyer signal, say that directly and design the next test.

```text
Bad: "This market looks promising, so build the MVP."
Good: "The plan depends on unverified urgency. Run 10 interviews before coding."
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Validate an idea | `facts -> assumptions -> tests -> kill criteria` |
| Scope an MVP | `stage -> wedge -> excluded features -> exit criteria` |
| Delegate to agents | `research -> coding -> automation -> human review` |

## Resources

- Source repository: <https://github.com/MackDing/ai-native-founder-playbook-skill>
- ClawHub listing: <https://clawhub.ai/mackding/ai-native-founder-playbook>
