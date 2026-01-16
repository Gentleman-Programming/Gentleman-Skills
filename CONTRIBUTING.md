# Contributing to Gentleman-Skills

Thank you for wanting to contribute! This document explains how to submit your own skills to the community collection.

## The Voting Process

Community skills go through a democratic approval process:

```
1. Submit PR ──> 2. Community Review ──> 3. Voting Period ──> 4. Decision
   (7 days)         (reactions)            (count votes)       (accept/reject)
```

### Timeline

| Phase | Duration | What Happens |
|-------|----------|--------------|
| Review | Days 1-7 | Community reviews and discusses the skill |
| Voting | Days 1-7 | Members vote using GitHub reactions |
| Decision | Day 8 | Maintainers count votes and merge or close |

### Voting Rules

- **How to vote**: Use reactions on the PR
  - Approve: Any positive reaction
  - Reject: "Thumbs down" reaction
- **Acceptance criteria**: `positive votes > negative votes`
- **Minimum votes**: At least 3 total votes required
- **Tie breaker**: Maintainers decide in case of a tie

### Fast-Track

Maintainers may fast-track exceptional skills that:
- Fill an obvious gap in the collection
- Are exceptionally well-documented
- Come from recognized community members

## How to Submit a Skill

### Step 1: Fork and Clone

```bash
# Fork the repo on GitHub, then:
git clone https://github.com/YOUR_USERNAME/Gentleman-Skills.git
cd Gentleman-Skills
```

### Step 2: Create Your Skill

Create a new folder in `community/` with your skill:

```bash
mkdir -p community/your-skill-name
```

Your skill MUST include a `SKILL.md` file. Use the [SKILL_TEMPLATE.md](SKILL_TEMPLATE.md) as a starting point.

### Step 3: Skill Requirements

Your skill must:

- [ ] Have a clear, descriptive name (e.g., `react-native`, `electron`, `prisma`)
- [ ] Include a `SKILL.md` with proper frontmatter
- [ ] Define clear trigger conditions
- [ ] Provide actionable patterns (not just documentation links)
- [ ] Include at least 3 code examples
- [ ] List anti-patterns to avoid
- [ ] Be original (not a copy of existing skills)
- [ ] Be tested with Claude Code or OpenCode

### Step 4: Submit Pull Request

```bash
git checkout -b add-skill-your-skill-name
git add community/your-skill-name
git commit -m "feat(community): add your-skill-name skill"
git push origin add-skill-your-skill-name
```

Then open a PR on GitHub with:

- **Title**: `[Community Skill] Your Skill Name`
- **Description**: Fill out the PR template
- **Labels**: `community-skill`, `voting`

### Step 5: Respond to Feedback

During the review period:
- Answer questions from the community
- Make improvements based on feedback
- Be respectful and open to suggestions

## Skill Quality Guidelines

### Good Skills

- **Specific**: Focus on one technology/framework
- **Actionable**: Provide concrete patterns, not vague advice
- **Current**: Use the latest stable version
- **Tested**: Verified to work with AI assistants
- **Well-documented**: Clear explanations and examples

### What to Avoid

- Copying official documentation verbatim
- Overly broad skills (e.g., "JavaScript" instead of "React 19")
- Outdated patterns from old versions
- Skills without code examples
- Duplicate skills that already exist

## After Acceptance

Once your skill is accepted:

1. It will be merged into `community/`
2. Added to the README's community table
3. You'll be credited as the author
4. The community can use and improve it

## Updating Existing Skills

To update an existing community skill:

1. Open a PR with your changes
2. Explain what you're improving
3. Same voting process applies for major changes
4. Minor fixes (typos, broken links) can be fast-tracked

## Questions?

- Open an issue with the `question` label
- Join the [Gentleman Programming Discord](https://discord.gg/gentleman-programming)

---

Thank you for contributing to the community!
