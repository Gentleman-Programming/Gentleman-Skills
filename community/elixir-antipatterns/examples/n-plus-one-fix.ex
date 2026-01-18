# n-plus-one-fix.ex - Correct Ecto query optimization patterns

defmodule MyApp.Posts do
  @moduledoc """
  Post queries optimized to avoid N+1 problems.
  Always preload associations, never query inside loops.
  """

  alias MyApp.{Repo, Post, User, Comment}
  import Ecto.Query

  # ============================================
  # CORRECT: Preload associations
  # ============================================

  @spec list_posts_with_authors() :: [Post.t()]
  def list_posts_with_authors do
    Post
    |> Repo.all()
    |> Repo.preload(:author)
  end

  @spec list_posts_with_everything() :: [Post.t()]
  def list_posts_with_everything do
    Post
    |> Repo.all()
    |> Repo.preload([:author, :comments, :tags])
  end

  # ============================================
  # CORRECT: Join when filtering by association
  # ============================================

  @spec list_posts_by_author_country(String.t()) :: [Post.t()]
  def list_posts_by_author_country(country) do
    Post
    |> join(:inner, [p], a in assoc(p, :author))
    |> where([p, a], a.country == ^country)
    |> preload([p, a], author: a)
    |> Repo.all()
  end

  @spec list_popular_posts_with_comments(integer()) :: [Post.t()]
  def list_popular_posts_with_comments(min_likes) do
    Post
    |> where([p], p.likes > ^min_likes)
    |> preload(:comments)
    |> order_by(desc: :likes)
    |> limit(10)
    |> Repo.all()
  end

  # ============================================
  # CORRECT: Nested preloads
  # ============================================

  @spec list_posts_with_authors_and_profiles() :: [Post.t()]
  def list_posts_with_authors_and_profiles do
    Post
    |> Repo.all()
    |> Repo.preload(author: [:profile, :settings])
  end

  # ============================================
  # CORRECT: Conditional preload
  # ============================================

  @spec list_posts(boolean()) :: [Post.t()]
  def list_posts(include_comments? \\ false) do
    query = from p in Post

    if include_comments? do
      query |> Repo.all() |> Repo.preload(:comments)
    else
      Repo.all(query)
    end
  end

  # ============================================
  # MIGRATION: Always add indexes on foreign keys
  # ============================================

  def migration_example do
    quote do
      create table(:posts) do
        add :title, :string
        add :body, :text
        add :author_id, references(:users, on_delete: :delete_all)
        add :published_at, :utc_datetime

        timestamps()
      end

      # Index on foreign key (CRITICAL for joins/preloads)
      create index(:posts, [:author_id])

      # Index on frequently queried columns
      create index(:posts, [:published_at])
      create index(:posts, [:author_id, :published_at])
    end
  end

  # ============================================
  # PERFORMANCE COMPARISON
  # ============================================

  def performance_comparison do
    # ❌ BAD: N+1 queries
    # 100 posts = 101 queries (1 posts + 100 authors)
    posts = Repo.all(Post)

    Enum.map(posts, fn post ->
      author = Repo.get(User, post.author_id)
      {post, author}
    end)

    # ✅ CORRECT: 2 queries total
    # 100 posts = 2 queries (1 posts + 1 authors join)
    Post |> Repo.all() |> Repo.preload(:author)
  end
end
