# Elixir Anti-Patterns - Extended Reference

> **Complete catalog** of 40+ anti-patterns for Elixir/Phoenix applications.  
> **For AI assistants**: Use `SKILL.md` (core patterns). This is reference documentation.

---

## Critical Patterns

### Pattern 1: Monadic Error Handling

**Use tagged tuples for business errors, never exceptions.**

Elixir functions should return `{:ok, result}` or `{:error, reason}` for expected failures. This makes errors explicit in function specs and forces callers to handle them via pattern matching.

```elixir
# ✅ CORRECT - Errors as values
@spec fetch_user(String.t()) :: {:ok, User.t()} | {:error, :not_found}
def fetch_user(id) do
  case Repo.get(User, id) do
    nil -> {:error, :not_found}
    user -> {:ok, user}
  end
end

# Usage forces error handling
case fetch_user(id) do
  {:ok, user} -> process(user)
  {:error, :not_found} -> handle_missing()
end
```

### Pattern 2: Separation of Concerns (Phoenix Context Pattern)

**Isolate business logic in contexts, keep views thin.**

Phoenix LiveView components should only coordinate UI events. All validation, queries, and business rules belong in context modules for testability and reusability.

```elixir
# ✅ CORRECT - LiveView delegates to context
def handle_event("create", params, socket) do
  case Accounts.create_user(params) do
    {:ok, user} -> 
      {:noreply, redirect(socket, to: user_path(socket, :show, user))}
    {:error, changeset} -> 
      {:noreply, assign(socket, changeset: changeset)}
  end
end

# Context handles all business logic
defmodule Accounts do
  @spec create_user(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> validate_business_rules()
    |> Repo.insert()
  end
end
```

### Pattern 3: Ecto Query Optimization

**Always preload associations, never query inside loops (N+1).**

Loading associations inside `Enum.map` creates N+1 queries. Use `Repo.preload` to fetch all data in a single query.

```elixir
# ✅ CORRECT - Single query with preload
User 
|> Repo.all() 
|> Repo.preload(:posts)
|> Enum.map(fn user -> 
  process_user_with_posts(user, user.posts)
end)

# Performance: 100 users = 2 queries (users + posts)
# vs N+1: 101 queries (1 user query + 100 post queries)
```

### Pattern 4: Pure Function Design

**Separate computation from side effects for testability.**

Functions should either compute (pure) or perform I/O (coordinator), never both. This enables testing without mocks.

```elixir
# ✅ CORRECT - Pure calculation
def calculate_total(items) do
  Enum.reduce(items, 0, &(&1.price + &2))
end

# ✅ CORRECT - Coordinator handles I/O
def calculate_and_log_total(items) do
  total = calculate_total(items)  # Delegate to pure function
  Logger.info("Total: #{total}")
  total
end
```

### Pattern 5: Consistent Error Conventions

**Choose one error convention per module boundary.**

Mixing `{:ok, _}`, exceptions, and `nil` in the same module makes APIs unpredictable. Pick one and document it with `@spec`.

```elixir
# ✅ CORRECT - Uniform convention
defmodule UserService do
  @spec create(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  @spec delete(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @spec find(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  
  # All functions follow same pattern
end
```

---

## Code Examples

### Example 1: Error Handling with Tagged Tuples

```elixir
# ✅ Complete error handling pattern
defmodule UserService do
  alias MyApp.{Repo, User}
  
  @spec fetch_user(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def fetch_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
  
  @spec find_by_email(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def find_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
  
  @spec create(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
```

### Example 2: Phoenix LiveView with Context Separation

```elixir
# ✅ Thin LiveView component
defmodule MyAppWeb.UserLive.Index do
  use MyAppWeb, :live_view
  alias MyApp.Accounts
  
  def handle_event("create", %{"user" => params}, socket) do
    # All business logic in context
    case Accounts.create_user(params) do
      {:ok, user} -> 
        {:noreply, 
         socket
         |> put_flash(:info, "User created")
         |> redirect(to: ~p"/users/#{user}")}
      
      {:error, changeset} -> 
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
  
  def handle_event("delete", %{"id" => id}, socket) do
    case Accounts.delete_user(id) do
      {:ok, _user} -> 
        {:noreply, 
         socket
         |> put_flash(:info, "User deleted")
         |> assign(:users, Accounts.list_users())}
      
      {:error, reason} -> 
        {:noreply, put_flash(socket, :error, "Delete failed: #{reason}")}
    end
  end
end

# ✅ Context with all business logic
defmodule MyApp.Accounts do
  alias MyApp.{Repo, User}
  
  def list_users do
    User |> Repo.all() |> Repo.preload(:profile)
  end
  
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> validate_business_rules()
    |> Repo.insert()
  end
  
  def delete_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> Repo.delete(user)
    end
  end
  
  defp validate_business_rules(changeset) do
    # Complex validation logic here
    changeset
  end
end
```

### Example 3: Ecto Query Optimization

> **⚡ Performance Note**: Choose preload strategy based on your use case

```elixir
# ✅ Efficient query patterns
defmodule MyApp.Posts do
  alias MyApp.{Repo, Post, User}
  import Ecto.Query
  
  # Strategy 1: Repo.preload/2 (simple case)
  # Use when: You need ALL associations (no filtering)
  # Queries: 2 (SELECT posts + SELECT authors)
  # Best for: Simple 1-to-many loads
  def list_posts_with_authors do
    Post
    |> Repo.all()
    |> Repo.preload(:author)
  end
  
  # Strategy 2: join + preload in query (complex case)
  # Use when: You filter/sort BY association fields
  # Queries: 1 (SELECT with JOIN)
  # Best for: Filtering by author.country, sorting by author.name
  def list_posts_by_author_country(country) do
    Post
    |> join(:inner, [p], a in assoc(p, :author))
    |> where([p, a], a.country == ^country)
    |> preload([p, a], author: a)  # Reuse joined data
    |> Repo.all()
  end
  
  # Strategy 3: select_merge for partial loads
  # Use when: You only need 2-3 fields from association
  # Avoids loading entire author struct
  def list_posts_with_author_names do
    Post
    |> join(:left, [p], a in assoc(p, :author))
    |> select_merge([p, a], %{author_name: a.name, author_country: a.country})
    |> Repo.all()
  end
  
  # Correct: Index on frequently queried columns
  # In migration:
  def change do
    create table(:posts) do
      add :title, :string
      add :author_id, references(:users)
      timestamps()
    end
    
    create index(:posts, [:author_id])  # Index foreign key
    create index(:posts, [:inserted_at]) # Index for date queries
  end
end
```

### Example 4: Pure Functions and Side Effects

```elixir
# ✅ Separation of computation and I/O
defmodule MyApp.OrderCalculator do
  # Pure function - testable without mocks
  @spec calculate_total([LineItem.t()]) :: Decimal.t()
  def calculate_total(items) do
    items
    |> Enum.map(&(&1.price * &1.quantity))
    |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
  end
  
  @spec apply_discount(Decimal.t(), Decimal.t()) :: Decimal.t()
  def apply_discount(total, discount_percent) do
    discount = Decimal.mult(total, Decimal.div(discount_percent, 100))
    Decimal.sub(total, discount)
  end
end

# Coordinator handles side effects
defmodule MyApp.OrderService do
  alias MyApp.{OrderCalculator, Repo, Order}
  require Logger
  
  def process_order(order_id) do
    with {:ok, order} <- fetch_order(order_id),
         total <- OrderCalculator.calculate_total(order.items),
         final_total <- OrderCalculator.apply_discount(total, order.discount),
         {:ok, updated} <- update_order_total(order, final_total) do
      
      Logger.info("Order #{order_id} processed: #{final_total}")
      notify_customer(updated)
      {:ok, updated}
    end
  end
  
  defp fetch_order(id), do: # ... DB query
  defp update_order_total(order, total), do: # ... DB update
  defp notify_customer(order), do: # ... Email/notification
end
```

### Example 5: Monadic Error Propagation (Error.m Pattern)

```elixir
# ✅ Correct monadic error handling
# Assuming you have a custom Error.m monad implementation
defmodule MyApp.UserWorkflow do
  require Error
  
  def create_user_with_profile(user_attrs, profile_attrs) do
    Error.m do
      # All operations use <- for monadic bind
      user <- validate_user_attrs(user_attrs)
      saved_user <- insert_user(user)
      profile <- validate_profile_attrs(profile_attrs)
      saved_profile <- insert_profile(saved_user, profile)
      
      # Wrap non-monadic values
      welcome_msg <- generate_welcome_message(saved_user) |> Error.return()
      
      # Short-circuits on first {:error, _}
      send_welcome_email(saved_user, welcome_msg)
    end
  end
  
  defp validate_user_attrs(attrs) do
    # Returns {:ok, validated} or {:error, reason}
  end
  
  defp insert_user(user), do: Repo.insert(user)
  defp insert_profile(user, profile), do: Repo.insert(profile)
end
```

### Example 6: Module Size Management

```elixir
# ✅ CORRECT - Split large modules by responsibility
# Before: UserService (850 lines - TOO LARGE)
# After: Split into cohesive modules

# Validation logic - 80 lines
defmodule MyApp.UserValidator do
  def validate_registration(attrs) do
    # Email format, password strength, etc.
  end
end

# Database queries - 60 lines
defmodule MyApp.UserRepository do
  def get_by_id(id), do: # ...
  def get_by_email(email), do: # ...
  def list_active_users, do: # ...
end

# Business logic coordinator - 120 lines
defmodule MyApp.UserService do
  alias MyApp.{UserValidator, UserRepository, Mailer}
  
  def create_user(attrs) do
    with {:ok, validated} <- UserValidator.validate_registration(attrs),
         {:ok, user} <- UserRepository.insert(validated),
         :ok <- Mailer.send_welcome_email(user) do
      {:ok, user}
    end
  end
end
```

### Example 7: ExUnit Testing Best Practices

```elixir
# ✅ CORRECT - Independent, parallel tests
defmodule MyApp.UserServiceTest do
  use MyApp.DataCase, async: true  # Parallel execution
  alias MyApp.UserService
  
  # Each test gets fresh data via setup
  setup do
    user = insert(:user, email: "test_#{System.unique_integer()}@example.com")
    {:ok, user: user}
  end
  
  describe "fetch_user/1" do
    test "returns user when exists", %{user: user} do
      assert {:ok, found} = UserService.fetch_user(user.id)
      assert found.id == user.id
      assert found.email == user.email
    end
    
    test "returns error when not found" do
      assert {:error, :not_found} = UserService.fetch_user("nonexistent")
    end
  end
  
  describe "create_user/1" do
    test "creates user with valid attributes" do
      attrs = %{name: "John", email: "john@example.com"}
      
      assert {:ok, user} = UserService.create_user(attrs)
      assert user.name == "John"
      assert user.email == "john@example.com"
    end
    
    test "returns error with invalid attributes" do
      attrs = %{name: "", email: "invalid"}
      
      assert {:error, changeset} = UserService.create_user(attrs)
      assert %{name: ["can't be blank"], email: ["invalid format"]} = 
             errors_on(changeset)
    end
  end
end
```

---

## All Anti-Patterns

### 1. Don't: Use `raise` for Business Errors

**Problem**: Expected failures (user not found, validation failed) should be values, not exceptions.

```elixir
# ❌ BAD - Crashes on expected error
def fetch_user(id) do
  Repo.get(User, id) || raise "User not found"
end

# Caller must use try/rescue (non-idiomatic)
try do
  fetch_user(id)
rescue
  _ -> handle_error()
end
```

**Why it's bad**: 
- Hides error cases from `@spec`
- Forces try/rescue (not composable)
- Treats expected failures as unexpected crashes

### 2. Don't: Return `nil` for Errors

**Problem**: Loses error context, forces defensive nil checks everywhere.

```elixir
# ❌ BAD - What went wrong?
def find_user(email) do
  Repo.get_by(User, email: email)  # Returns nil if not found
end

# Caller can't distinguish "not found" from "DB error" from "invalid input"
case find_user(email) do
  nil -> # Which error? Who knows!
  user -> # Process
end
```

### 3. Don't: Mix Error Conventions

**Problem**: Inconsistent APIs are unpredictable and hard to use.

```elixir
# ❌ BAD - Module with mixed conventions
defmodule UserService do
  def create(attrs), do: Repo.insert(changeset(attrs))  # {:ok, _} | {:error, _}
  def delete(id), do: Repo.delete!(Repo.get(User, id))  # Raises exception
  def find(id), do: Repo.get(User, id)                   # Returns nil
end
```

### 4. Don't: Use `=` Inside `Error.m` Blocks

**Problem**: Breaks monadic chain, silences errors.

```elixir
# ❌ BAD - validate() errors are silenced
Error.m do
  user <- fetch_user(id)
  validated = validate(user)  # If validate returns {:error, _}, BOOM!
  save(validated)
end

# ✅ CORRECT - All binds use <-
Error.m do
  user <- fetch_user(id)
  validated <- validate(user)  # Auto short-circuits on error
  save(validated)
end
```

### 5. Don't: Put Business Logic in LiveView

**Problem**: Logic tied to UI framework, not testable without browser.

```elixir
# ❌ BAD - Validation and queries in LiveView
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

**Why it's bad**:
- Can't test validation without Phoenix
- Can't reuse logic in API controllers
- Violates separation of concerns

### 6. Don't: Put I/O in Pure Functions

**Problem**: Side effects prevent testing without mocks.

```elixir
# ❌ BAD - Logger call in calculation
def calculate_total(items) do
  total = Enum.reduce(items, 0, &(&1.price + &2))
  Logger.info("Total: #{total}")  # Side effect!
  total
end

# Can't test without capturing logs or mocking Logger
```

### 7. Don't: Store Derived Data in LiveView Assigns

**Problem**: Data duplication, manual sync, bugs.

```elixir
# ❌ BAD - Computed values in assigns
assign(socket,
  users: users,
  user_count: length(users),     # Duplicates data
  has_users: users != []          # Duplicates data
)

# What if users changes but you forget to update user_count?
```

### 8. Don't: Query Inside Loops (N+1)

**Problem**: Exponential performance degradation.

```elixir
# ❌ BAD - 101 queries for 100 users
users = Repo.all(User)
Enum.map(users, fn user ->
  posts = Repo.all(from p in Post, where: p.user_id == ^user.id)
  {user, posts}
end)

# 100 users = 10 seconds (100ms per query)
```

### 9. Don't: Use Transactions for Single Operations

**Problem**: Unnecessary overhead and database locks.

```elixir
# ❌ BAD - Transaction wrapping single insert
Repo.transaction(fn -> 
  Repo.insert!(user) 
end)

# ✅ CORRECT - No transaction needed
Repo.insert(user)
```

### 10. Don't: Query Without Indexes

**Problem**: Full table scans on large tables.

```elixir
# ❌ BAD - Frequently queried column without index
def find_by_email(email) do
  Repo.get_by(User, email: email)  # Full table scan!
end

# In migration - no index on email column
create table(:users) do
  add :email, :string  # Will be slow on 1M+ rows
end
```

### 11. Don't: Use Tasks for CPU-Bound Operations

**Problem**: Scheduling overhead without benefit.

```elixir
# ❌ BAD - Task for simple calculation
def calculate_total(items) do
  Task.async(fn -> Enum.sum(items) end) |> Task.await()
end

# Process overhead > calculation time
```

### 12. Don't: Write Tests Without Assertions

**Problem**: False sense of coverage, doesn't verify behavior.

```elixir
# ❌ BAD - What are we testing?
test "creates user" do
  UserService.create_user(%{name: "Juan"})
  # No assertion - test always passes!
end
```

### 13. Don't: Write Dependent Tests

**Problem**: Tests fail when run in different order, not parallelizable.

```elixir
# ❌ BAD - Tests share state
defmodule UserServiceTest do
  use ExUnit.Case  # No async: true
  
  test "creates user" do
    {:ok, _} = UserService.create_user(%{email: "test@example.com"})
  end
  
  test "finds user" do
    # Assumes previous test ran first!
    {:ok, user} = UserService.find_by_email("test@example.com")
  end
end
```

### 14. Don't: Chain More Than 4 Steps in `with`

**Problem**: Violates Single Responsibility Principle.

```elixir
# ❌ BAD - Too many responsibilities
with {:ok, a} <- step1(),
     {:ok, b} <- step2(a),
     {:ok, c} <- step3(b),
     {:ok, d} <- step4(c),
     {:ok, e} <- step5(d),
     {:ok, f} <- step6(e) do
  {:ok, f}
end

# ✅ CORRECT - Group into cohesive functions
with {:ok, validated} <- validate_and_fetch(id),
     {:ok, processed} <- process_business_rules(validated),
     {:ok, result} <- persist_and_notify(processed) do
  {:ok, result}
end
```

### 15. Don't: Let Modules Exceed 800 Lines

**Problem**: Multiple responsibilities, low cohesion.

```elixir
# ❌ BAD - Monolithic module (850 lines)
defmodule UserService do
  # Validation (200 lines)
  # Queries (150 lines)
  # Business logic (300 lines)
  # Email sending (100 lines)
  # Report generation (100 lines)
end

# Split into: UserValidator, UserRepository, UserService, UserMailer, UserReports
```

---

## Resources

- [Elixir Official Style Guide](https://hexdocs.pm/elixir/naming-conventions.html)
- [Phoenix Context Guidelines](https://hexdocs.pm/phoenix/contexts.html)
- [Ecto Query Performance](https://hexdocs.pm/ecto/Ecto.Query.html#module-query-performance)
- [ExUnit Best Practices](https://hexdocs.pm/ex_unit/ExUnit.html)
- [Credo Static Analysis](https://github.com/rrrene/credo)

---

**Version**: 1.0  
**Last Updated**: January 2026  
**Note**: This is the complete reference. For AI assistant usage, see `SKILL.md` (core patterns).