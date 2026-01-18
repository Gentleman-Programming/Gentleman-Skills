# Elixir Anti-Patterns Skill

Community contribution for Gentleman-Skills: Core catalog of 8 critical anti-patterns for Elixir/Phoenix applications.

## Structure

This skill uses a **hybrid approach** to balance LLM context limits with comprehensive documentation:

```
elixir-antipatterns/
├── SKILL.md          # Core 8 patterns (322 lines as of v1.0)
├── EXTENDED.md       # Complete 40+ patterns (706 lines)
├── examples/         # Executable Elixir code samples
│   ├── error-handling.ex
│   ├── liveview-separation.ex
│   └── n-plus-one-fix.ex
└── README.md         # This file
```

### SKILL.md (Core - LLM Loaded)
**Optimized for code review and refactoring sessions**

Contains the top 8 most critical anti-patterns:
1. Use `raise` for business errors
2. Return `nil` for errors
3. Business logic in LiveView
4. N+1 queries
5. `=` inside `with` for failable operations
6. Query without indexes
7. Tests without assertions
8. Long `with` chains (>4 steps)

**Why separate files?**
- SKILL.md fits within LLM context windows 
- Aligns with Gentleman-Skills standard (150-388 line target)
- Includes ASCII diagram for Phoenix architecture visualization
- EXTENDED.md preserves all knowledge with advanced Ecto patterns
- examples/ provides copy-paste ready code

## What This Skill Covers

- **Error Handling**: Tagged tuples vs exceptions vs nil
- **Separation of Concerns**: Phoenix contexts vs business logic in views
- **Database Performance**: N+1 queries, indexing, transactions
- **Testing Best Practices**: Independent tests, assertions, async execution

## Why It's Valuable

- **Comprehensive Elixir/Phoenix skill**: Covers error handling, contexts, Ecto, testing
- **Code review optimized**: Trigger designed for PR reviews and refactoring
- **Visual aids**: ASCII diagrams for Phoenix Context Separation architecture
- **Advanced techniques**: EXTENDED.md documents 3 Ecto preload strategies

## Usage with AI Assistants

The AI will automatically load `SKILL.md` when working with Elixir code. For deeper reference:

```markdown
## Skills
When working with Elixir/Phoenix code, load the `elixir-antipatterns` skill.
For comprehensive patterns, reference `EXTENDED.md`.
```

## Testing

Validated with:
- ✅ Cursor on Elixir/Phoenix projects
- ✅ Production applications (2+ years)
- ✅ Mix format + Credo compliance

## Contributing

Created for [Gentleman-Skills](https://github.com/Gentleman-Programming/Gentleman-Skills).

## License

MIT License - Free to use and modify