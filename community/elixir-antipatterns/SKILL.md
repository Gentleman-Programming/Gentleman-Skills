---
name: elixir-antipatterns
description: >
  Core catalog of 8 critical Elixir/Phoenix anti-patterns covering error handling,
  separation of concerns, Ecto queries, and testing. 
  Trigger: During Elixir code review, refactoring sessions, or when writing Phoenix/Ecto code.
metadata:
  author: tsardinasGitHub
  version: "1.0"
---

# Elixir Anti-Patterns

Critical anti-patterns that compromise robustness and maintainability in Elixir/Phoenix applications.

> **Complement with**: `mix format` and `Credo` for style enforcement  
> **Extended reference**: See `EXTENDED.md` for 40+ patterns and deep-dive examples

---

## When to Use

**Topics:** Error handling (3 patterns) • Architecture (2 patterns) • Performance (2 patterns) • Testing (1 pattern)

Load this skill when:
- Writing Elixir modules and functions
- Working with Phoenix Framework (Controllers, LiveView)
- Building Ecto schemas and database queries
- Implementing BEAM concurrency (Task, GenServer)
- Handling errors with tagged tuples
- Writing tests with ExUnit

---

## Critical Patterns

Quick reference to the 8 core patterns this skill enforces:

1. **Tagged Tuples**: Return `{:ok, value} | {:error, reason}` instead of `nil` or exceptions
2. **Explicit @spec**: Document error cases in function signatures
3. **Context Separation**: Business logic in contexts, not LiveView
4. **Preload Associations**: Use `Repo.preload/2` to avoid N+1 queries
5. **with Arrow Binding**: Use `<-` for all failable operations in `with`
6. **Database Indexes**: Index frequently queried columns
7. **Test Assertions**: Every test must assert expected behavior
8. **Cohesive Functions**: Group `with` chains >4 steps into functions

> See `## Anti-Patterns` section below for detailed ❌ BAD / ✅ CORRECT code examples.

---

## Code Examples

### Example 1: Error Handling with Tagged Tuples

```elixir
# ✅ CORRECT - Errors as values, explicit in @spec
defmodule UserService do
  @spec fetch_user(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def fetch_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end

# ❌ BAD - Exceptions for business errors
def fetch_user(id) do
  Repo.get(User, id) || raise "User not found"
end
```

### Example 2: Phoenix LiveView with Context Separation

```
Architecture Layers:
  User Request → LiveView (UI only) → Context (business logic) → Schema/Repo (data)
               ↓                    ↓                           ↓
           handle_event()     Accounts.create_user()      Repo.insert()
```

```elixir
# ✅ CORRECT - Thin LiveView, logic in context
defmodule MyAppWeb.UserLive.Index do
  use MyAppWeb, :live_view
  
  def handle_event("create", params, socket) do
    case Accounts.create_user(params) do
      {:ok, user} -> {:noreply, redirect(socket, to: ~p"/users/#{user}")}
      {:error, changeset} -> {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

# ❌ BAD - Business logic in LiveView
def handle_event("create", %{"user" => params}, socket) do
  if String.length(params["name"]) < 3 do
    {:noreply, put_flash(socket, :error, "Too short")}
  else
    case Repo.insert(User.changeset(%User{}, params)) do
      {:ok, user} -> send_email(user); redirect(socket)
    end
  end
end
```

### Example 3: Ecto N+1 Query Optimization

```elixir
# ✅ CORRECT - Preload associations (2 queries total)
users = User |> Repo.all() |> Repo.preload(:posts)
Enum.map(users, fn user -> process(user, user.posts) end)

# Note: For complex filtering (e.g., WHERE posts.status = 'published'),
# use join + preload in the query itself. See EXTENDED.md for advanced patterns.

# ❌ BAD - Query in loop (101 queries for 100 users)
users = Repo.all(User)
Enum.map(users, fn user ->
  posts = Repo.all(from p in Post, where: p.user_id == ^user.id)
  {user, posts}
end)
```

---

## Anti-Patterns

### Error Management

#### Don't: Use `raise` for Business Errors

```elixir
# ❌ BAD
def fetch_user(id) do
  Repo.get(User, id) || raise "User not found"
end

# ✅ CORRECT
@spec fetch_user(String.t()) :: {:ok, User.t()} | {:error, :not_found}
def fetch_user(id) do
  case Repo.get(User, id) do
    nil -> {:error, :not_found}
    user -> {:ok, user}
  end
end
```

**Why**: `@spec` documents errors, pattern matching forces explicit handling.

---

#### Don't: Return `nil` for Errors

```elixir
# ❌ BAD - No context on failure
def find_user(email), do: Repo.get_by(User, email: email)

# ✅ CORRECT - Explicit error reason
@spec find_user(String.t()) :: {:ok, User.t()} | {:error, :not_found}
def find_user(email) do
  case Repo.get_by(User, email: email) do
    nil -> {:error, :not_found}
    user -> {:ok, user}
  end
end
```

---

#### Don't: Use `=` Inside `with` for Failable Operations

```elixir
# ❌ BAD - Validate errors silenced
with {:ok, user} <- fetch_user(id),
     validated = validate(user),  # ← Doesn't check for {:error, _}
     {:ok, saved} <- save(validated) do
  {:ok, saved}
end

# ✅ CORRECT - All operations use <-
with {:ok, user} <- fetch_user(id),
     {:ok, validated} <- validate(user),
     {:ok, saved} <- save(validated) do
  {:ok, saved}
end
```

---

### Architecture & Boundaries

#### Don't: Put Business Logic in LiveView

```elixir
# ❌ BAD - Validation in view
def handle_event("create", %{"user" => params}, socket) do
  if String.length(params["name"]) < 3 do
    {:noreply, put_flash(socket, :error, "Too short")}
  else
    case Repo.insert(User.changeset(%User{}, params)) do
      {:ok, user} -> redirect(socket)
    end
  end
end

# ✅ CORRECT - Delegate to context
def handle_event("create", params, socket) do
  case Accounts.create_user(params) do
    {:ok, user} -> {:noreply, redirect(socket, to: ~p"/users/#{user}")}
    {:error, changeset} -> {:noreply, assign(socket, changeset: changeset)}
  end
end
```

**Why**: Contexts testable without Phoenix, logic reusable.

---

#### Don't: Chain More Than 4 Steps in `with`

```elixir
# ❌ BAD - Too many responsibilities
with {:ok, a} <- step1(),
     {:ok, b} <- step2(a),
     {:ok, c} <- step3(b),
     {:ok, d} <- step4(c),
     {:ok, e} <- step5(d) do
  {:ok, e}
end

# ✅ CORRECT - Group into cohesive functions
with {:ok, validated} <- validate_and_fetch(id),
     {:ok, processed} <- process_business_rules(validated),
     {:ok, result} <- persist_and_notify(processed) do
  {:ok, result}
end
```

---

### Data & Performance

#### Don't: Query Inside Loops (N+1)

```elixir
# ❌ BAD - 101 queries for 100 users
users = Repo.all(User)
Enum.map(users, fn user ->
  posts = Repo.all(from p in Post, where: p.user_id == ^user.id)
end)

# ✅ CORRECT - 2 queries total
User |> Repo.all() |> Repo.preload(:posts)
```

**Impact**: 100 users with N+1 = 10 seconds vs 5ms with preload.

---

#### Don't: Query Without Indexes

```elixir
# ❌ BAD - No index on frequently queried column
# Migration:
create table(:users) do
  add :email, :string
end

# ✅ CORRECT - Add index
create table(:users) do
  add :email, :string
end
create unique_index(:users, [:email])
```

**Why**: Full table scan on 1M+ rows vs instant index lookup.

---

### Testing

#### Don't: Write Tests Without Assertions

```elixir
# ❌ BAD - What's being tested?
test "creates user" do
  UserService.create_user(%{name: "Juan"})
end

# ✅ CORRECT - Assert expected behavior
test "creates user successfully" do
  assert {:ok, user} = UserService.create_user(%{name: "Juan"})
  assert user.name == "Juan"
end
```

---

## Quick Reference

| Situation | Anti-Pattern | Correct Pattern |
|-----------|--------------|-----------------|
| **Error handling** | `raise "Not found"` | `{:error, :not_found}` |
| **Missing data** | Return `nil` | `{:error, :not_found}` |
| **Business logic** | In LiveView | In context modules |
| **Associations** | `Enum.map` + `Repo.get` | `Repo.preload` |
| **with chains** | `validated = fn()` | `{:ok, validated} <- fn()` |
| **Frequent queries** | No index | `create index(:table, [:column])` |
| **Testing** | No assertions | `assert` expected behavior |
| **Complex logic** | 6+ step `with` | Group into 3 functions |

---

## Resources

- [Elixir Style Guide](https://hexdocs.pm/elixir/naming-conventions.html)
- [Phoenix Contexts](https://hexdocs.pm/phoenix/contexts.html)
- [Ecto Query Performance](https://hexdocs.pm/ecto/Ecto.Query.html)
- [ExUnit Best Practices](https://hexdocs.pm/ex_unit/ExUnit.html)
- **Extended patterns**: See `EXTENDED.md` for 40+ anti-patterns