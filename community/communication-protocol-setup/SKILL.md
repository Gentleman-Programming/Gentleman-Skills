---
name: communication-protocol-setup
description: >
  Set up AI communication style via interactive Q&A.
  Trigger: When a user wants to configure or calibrate how an AI assistant talks to them, when onboarding a non-technical user to an AI tool, when the user feels the AI's communication style is wrong.
metadata:
  author: cez0060405
  version: "1.0"
---

## When to Use

Load this skill when:
- The user asks to configure or calibrate how an AI communicates with them ("帮我配置沟通协议", "怎么用你", "新手配置").
- The user switches to a new AI tool/agent and wants to establish rapport quickly.
- The user feels the AI's communication style is wrong and wants to recalibrate.
- The user is a non-technical person setting up an AI assistant for the first time.

Do NOT use for technical users who already know exactly how they want the AI to behave, or when the user just wants a one-off answer.

## Critical Patterns

### Pattern 1: Interactive Q&A (one or two questions at a time)

Ask the 8 questions in order, each in plain language. Never dump all 8 at once — it overwhelms non-technical users.

```text
Q1 Technical background: "你是程序员/技术人，还是普通用户？"
Q2 Goal style: "你交代任务时，喜欢给大概方向还是讲清每一步？"
Q3 Acceptance style: "AI 做完东西你希望：A) 直接给结果 B) 做几个版本让你挑 C) 先看方案再动手？"
Q4 Proactivity: "你希望 AI 多主动还是多问？"
Q5 Feedback style: "不满意时你能说清哪里不对，还是只能说'感觉不对'？"
Q6 Reply length: "你希望 AI 回复：A) 简短结论 B) 详细报告 C) 看情况？"
Q7 Red lines: "AI 做哪些事之前必须问你？比如删文件、重启、花钱、改配置。"
Q8 Cost: "你担心 AI 花钱吗？有预算上限吗？"
```

After each answer, restate in one sentence and let the user confirm or correct. If the user answers vaguely, offer 2-3 options to pick from.

### Pattern 2: Generate the protocol

Output a customized communication protocol with a one-line judgment standard, communication rules, red lines, and a boundary table.

```markdown
# 沟通协议（定制版）

## 一句话判断标准
能反悔直接干，不能反悔先问。

## 沟通方式
1. **目标**：<per Q2>
2. **验收**：<per Q3>
3. **反馈**：<per Q5>
4. **主动性**：<per Q4>
5. **术语**：<per Q1>
6. **回复**：<per Q6>
7. **过程透明**：简单说为什么；完整过程存档可查
8. **语气**：无所谓，核心是听懂
9. **汇报节奏**：关键节点
10. **记忆**：AI 主动记偏好
11. **平等纠错**：用户也会错，AI 可直接指出

## 红线（不可逾越）
<per Q7>

## 边界判断
| 情况 | 动作 |
|---|---|
| 能反悔（改配置、写文件、跑任务） | 直接干 |
| 不能反悔（删数据、覆盖、杀进程、花钱） | 先问 |
| 用户喊停 | 立即停，不辩解 |
```

### Pattern 3: Multi-tool sync + recalibration

Generate once, export multiple copies (main / AGENTS.md / custom-instructions / paste-able) for multi-tool sync. On recalibration, change only the rule the user points at, never redo everything.

```text
Main config (source of truth) → AGENTS.md version → Custom-instructions version → Paste-able version
Recalibration: read existing config → ask "哪条不对?" → change only that rule → re-export all copies
```

## Code Examples

### Example 1: Full Q&A flow

```text
User: "帮我配置沟通协议，我是普通用户，不太懂技术。"
Agent: "好，我们一步步来。先问第一个：你交代任务时，是喜欢给一个大概方向让 AI 自己琢磨，还是喜欢把每一步都讲清楚？"
User: "大概方向吧，我不懂细节。"
Agent: "明白，你给大方向，AI 多问几轮翻译成计划，确认后再动手。下一个问题：AI 做完东西，你希望它直接给一个结果，还是做几个版本让你挑？"
```

### Example 2: Apply to Claude Code / Codex

```text
Store the generated protocol as CLAUDE.md / AGENTS.md in the project root.
The AI auto-loads it on every session.
Tell the user the exact file path.
```

### Example 3: Recalibration

```text
User: "上次配的哪条不对，AI 太啰嗦了。"
Agent: "明白，只改'回复'这一条：从详细报告改成简短结论。其他规则保持不变。改完我帮你重新生成所有工具的配置。"
```

## Anti-Patterns

### Don't: Dump all 8 questions at once

```text
BAD: "请回答以下8个问题：1.技术背景？2.目标风格？3.验收方式？..."
GOOD: "先问第一个：你交代任务时，喜欢给大概方向还是讲清每一步？"
```

### Don't: Redo the whole protocol on recalibration

```text
BAD: 用户说"AI太啰嗦"，AI 重新问全部8个问题，重写整个协议。
GOOD: 只改"回复"这一条，其他保持不变。
```

### Don't: Use standard tests for verification

```text
BAD: "请完成这份测试问卷来验证配置是否生效。"
GOOD: "配置后正常用几天，看这些体验指标有没有明显变好：AI 是否更少问'你到底要什么'、是否更主动、是否更简洁。"
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Ask questions | One or two at a time, plain language, restate after each |
| Generate protocol | One-line judgment + rules + red lines + boundary table |
| Apply | Store as CLAUDE.md / AGENTS.md / custom instructions / paste-able |
| Sync | One source of truth, export multiple copies |
| Recalibrate | Change only the rule the user points at |
| Verify | Tell user which experience metrics to watch, not standard tests |

## Resources

- [Agent Skills standard](https://agentskills.io)
- [Anthropic: How to create custom skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)