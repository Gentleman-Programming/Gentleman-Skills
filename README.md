# Gentleman-Skills

> Community-driven AI agent skills for Claude Code, OpenCode, Gemini CLI, Cursor, VS Code Copilot, Codex, Windsurf, Antigravity, and other AI assistants.

Skills are specialized instruction sets that teach AI assistants how to work with specific frameworks, libraries, and patterns. They provide on-demand context so the AI writes code following best practices and conventions.

## Philosophy

- **Curated Skills** - Personally crafted and battle-tested by [@Gentleman-Programming](https://github.com/Gentleman-Programming). These reflect MY way of thinking about code architecture - Scope Rule, file naming conventions, signals-first approach, and more. Some skills (like testing and Python) have been developed in collaboration with the team at [Prowler](https://github.com/prowler-cloud).

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

| Skill | Description | Author |
|-------|-------------|--------|
| [electron](community/electron) | Electron patterns for building cross-platform desktop applications. | @gentleman-programming |
| [elixir-antipatterns](community/elixir-antipatterns) | Core catalog of 8 critical Elixir/Phoenix anti-patterns covering error handling... | @tsardinasGitHub |
| [hexagonal-architecture-layers-java](community/hexagonal-architecture-layers-java) | Hexagonal architecture layering for Java services with strict boundaries. | @diegnghrmr |
| [java-21](community/java-21) | Java 21 language and runtime patterns for modern, safe code. | @diegnghrmr |
| [react-native](community/react-native) | React Native patterns for mobile app development with Expo and bare workflow. | @gentleman-programming |
| [spring-boot-3](community/spring-boot-3) | Spring Boot 3 patterns for configuration, DI, and web services. | @diegnghrmr |

## Supported Agents & Skills Directory

Each agent reads skills from a specific directory. Copy the skills you want into the right path for your agent:

| Agent | macOS / Linux | Windows |
|-------|---------------|---------|
| **Claude Code** | `~/.claude/skills/` | `%USERPROFILE%\.claude\skills\` |
| **OpenCode** | `~/.config/opencode/skills/` | `%USERPROFILE%\.config\opencode\skills\` |
| **Gemini CLI** | `~/.gemini/skills/` | `%USERPROFILE%\.gemini\skills\` |
| **Cursor** | `~/.cursor/skills/` | `%USERPROFILE%\.cursor\skills\` |
| **VS Code Copilot** | `~/.copilot/skills/` | `%USERPROFILE%\.copilot\skills\` |
| **Codex** | `~/.codex/skills/` | `%USERPROFILE%\.codex\skills\` |
| **Windsurf** | `~/.codeium/windsurf/skills/` | `%USERPROFILE%\.codeium\windsurf\skills\` |
| **Antigravity** | `~/.gemini/antigravity/skills/` | `%USERPROFILE%\.gemini\antigravity\skills\` |

Inside each `skills/` directory, every skill lives in its own folder with a `SKILL.md`:

```
skills/
  react-19/SKILL.md
  typescript/SKILL.md
  angular/core/SKILL.md
  playwright/SKILL.md
  ...
```

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/Gentleman-Programming/Gentleman-Skills.git

# Copy curated skills to your agent's skills directory
# Replace <SKILLS_DIR> with the path from the table above

# Example: Claude Code (macOS/Linux)
cp -r Gentleman-Skills/curated/* ~/.claude/skills/

# Example: OpenCode (macOS/Linux)
cp -r Gentleman-Skills/curated/* ~/.config/opencode/skills/

# Example: Gemini CLI (macOS/Linux)
cp -r Gentleman-Skills/curated/* ~/.gemini/skills/

# Example: Cursor (macOS/Linux)
cp -r Gentleman-Skills/curated/* ~/.cursor/skills/

# Or copy specific skills only
cp -r Gentleman-Skills/curated/react-19 ~/.claude/skills/
cp -r Gentleman-Skills/curated/typescript ~/.claude/skills/
```

### Manual Installation

1. Create the skills directory for your agent if it doesn't exist:
   ```bash
   # Example for Claude Code
   mkdir -p ~/.claude/skills

   # Example for Gemini CLI
   mkdir -p ~/.gemini/skills
   ```

2. Copy the skill folder(s) you want:
   ```bash
   cp -r curated/react-19 ~/.claude/skills/
   ```

3. Reference the skill in your agent's configuration file (e.g., `CLAUDE.md` for Claude Code):
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

## Other Resources

Looking for official Vercel skills? Check out [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills).

## License

MIT License - See [LICENSE](LICENSE) for details.

---

Made with care by [Gentleman Programming](https://github.com/Gentleman-Programming) and the community.
