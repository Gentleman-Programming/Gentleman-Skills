# Gentleman-Skills

> Community-driven AI agent skills for Claude Code, OpenCode, and other AI assistants.

Skills are specialized instruction sets that teach AI assistants how to work with specific frameworks, libraries, and patterns. They provide on-demand context so the AI writes code following best practices and conventions.

## Philosophy

This repository is divided into two sections:

- **Curated Skills** - Personally crafted and battle-tested by [@Gentleman-Programming](https://github.com/Gentleman-Programming). These reflect a specific way of thinking about code architecture, patterns, and best practices.

- **Community Skills** - Created by the community, for the community. These go through a democratic voting process before being accepted.

## Curated Skills

These skills represent patterns and practices I've personally tested and refined over years of development.

### Contributing to this Repo?

> **Start here!** Use the [github-pr](curated/github-pr) skill to create proper PRs with conventional commits.

| Skill | Description | Trigger |
|-------|-------------|---------|
| [github-pr](curated/github-pr) | Create quality PRs with conventional commits | When creating PRs or contributing |
| [skill-creator](curated/skill-creator) | Create new skills | When creating new AI agent skills |

### Frontend

| Skill | Description | Trigger |
|-------|-------------|---------|
| [angular/core](curated/angular/core) | Standalone components, signals, inject, zoneless | When creating Angular components |
| [angular/forms](curated/angular/forms) | Signal Forms, Reactive Forms | When working with Angular forms |
| [angular/performance](curated/angular/performance) | NgOptimizedImage, @defer, lazy loading, SSR | When optimizing Angular apps |
| [angular/architecture](curated/angular/architecture) | Scope Rule, project structure, file naming | When structuring Angular projects |
| [react-19](curated/react-19) | React 19 patterns with React Compiler | When writing React components |
| [nextjs-15](curated/nextjs-15) | Next.js 15 App Router patterns | When working with Next.js |
| [typescript](curated/typescript) | TypeScript strict patterns | When writing TypeScript code |
| [tailwind-4](curated/tailwind-4) | Tailwind CSS 4 patterns | When styling with Tailwind |
| [zod-4](curated/zod-4) | Zod 4 schema validation | When using Zod for validation |
| [zustand-5](curated/zustand-5) | Zustand 5 state management | When managing React state |

### Backend & AI

| Skill | Description | Trigger |
|-------|-------------|---------|
| [ai-sdk-5](curated/ai-sdk-5) | Vercel AI SDK 5 patterns | When building AI chat features |
| [django-drf](curated/django-drf) | Django REST Framework patterns | When building REST APIs with Django |

### Testing

| Skill | Description | Trigger |
|-------|-------------|---------|
| [playwright](curated/playwright) | Playwright E2E testing | When writing E2E tests |
| [pytest](curated/pytest) | Python pytest patterns | When writing Python tests |

### Workflow

| Skill | Description | Trigger |
|-------|-------------|---------|
| [jira-task](curated/jira-task) | Jira task creation | When creating Jira tasks |
| [jira-epic](curated/jira-epic) | Jira epic creation | When creating Jira epics |

## Community Skills

Skills contributed by the community and approved through our voting process.

| Skill | Description | Author | Votes |
|-------|-------------|--------|-------|
| *Coming soon* | Be the first to contribute! | - | - |

## Installation

### For Claude Code / OpenCode

Copy the skills you want to use to your Claude configuration:

```bash
# Clone the repository
git clone https://github.com/Gentleman-Programming/Gentleman-Skills.git

# Copy curated skills to Claude config
cp -r Gentleman-Skills/curated/* ~/.claude/skills/

# Or copy specific skills
cp -r Gentleman-Skills/curated/react-19 ~/.claude/skills/
cp -r Gentleman-Skills/curated/typescript ~/.claude/skills/
```

### Manual Installation

1. Create the skills directory if it doesn't exist:
   ```bash
   mkdir -p ~/.claude/skills
   ```

2. Copy the skill folder(s) you want:
   ```bash
   cp -r curated/react-19 ~/.claude/skills/
   ```

3. Reference the skill in your project's `CLAUDE.md` or global `~/.claude/CLAUDE.md`:
   ```markdown
   ## Skills
   When working with React, read `~/.claude/skills/react-19/SKILL.md` first.
   ```

## How Skills Work

Each skill contains a `SKILL.md` file with:

1. **Trigger conditions** - When the AI should load this skill
2. **Patterns and rules** - Specific coding conventions to follow
3. **Code examples** - Reference implementations
4. **Anti-patterns** - What to avoid

When the AI detects a matching context (e.g., editing a React component), it reads the skill file and applies those patterns to its responses.

## Contributing

We welcome community contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process.

> **Pro tip**: Load the [github-pr](curated/github-pr) skill to create PRs that follow our conventions!

### Quick Overview

1. **Fork** this repository
2. **Create** your skill following the [skill template](SKILL_TEMPLATE.md)
3. **Submit** a Pull Request to the `community/` folder using [conventional commits](https://www.conventionalcommits.org/)
4. **Community votes** for 7 days using reactions
5. **Accepted** if more positive than negative votes

### Voting System

- Vote with reactions on the PR
- Voting period: **7 days**
- Acceptance criteria: `positive votes > negative votes`
- Maintainers can fast-track exceptional contributions

## Skill Structure

```
skill-name/
├── SKILL.md          # Main skill file (required)
├── examples/         # Code examples (optional)
└── README.md         # Skill documentation (optional)
```

## License

MIT License - See [LICENSE](LICENSE) for details.

---

Made with care by [Gentleman Programming](https://github.com/Gentleman-Programming) and the community.
