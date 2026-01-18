# error-handling.ex - Correct error handling patterns

defmodule MyApp.UserService do
  @moduledoc """
  User service with proper error handling using tagged tuples.
  All public functions return {:ok, result} | {:error, reason}.
  """

  alias MyApp.{Repo, User}
  import Ecto.Query

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

  @spec create(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec update(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec delete(String.t()) :: {:ok, User.t()} | {:error, :not_found | Ecto.Changeset.t()}
  def delete(id) do
    with {:ok, user} <- fetch_user(id) do
      Repo.delete(user)
    end
  end
end
