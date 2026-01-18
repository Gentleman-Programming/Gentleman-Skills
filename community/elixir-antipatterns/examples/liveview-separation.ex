# liveview-separation.ex - Correct separation between LiveView and Context

# ============================================
# LIVEVIEW - Thin, only handles UI coordination
# ============================================
defmodule MyAppWeb.UserLive.Index do
  use MyAppWeb, :live_view
  alias MyApp.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, users: Accounts.list_users())}
  end

  def handle_event("create", %{"user" => params}, socket) do
    # Delegate ALL business logic to context
    case Accounts.create_user(params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
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
        {:noreply, put_flash(socket, :error, "Cannot delete: #{reason}")}
    end
  end
end

# ============================================
# CONTEXT - All business logic and validation
# ============================================
defmodule MyApp.Accounts do
  @moduledoc """
  Accounts context handles all user-related business logic.
  Testable without Phoenix, reusable in API controllers.
  """

  alias MyApp.{Repo, User}
  import Ecto.Query

  @spec list_users() :: [User.t()]
  def list_users do
    User
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:profile)
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> validate_business_rules()
    |> Repo.insert()
    |> tap(&maybe_send_welcome_email/1)
  end

  @spec delete_user(String.t()) :: {:ok, User.t()} | {:error, :not_found | atom()}
  def delete_user(id) do
    case Repo.get(User, id) do
      nil ->
        {:error, :not_found}

      user ->
        if user.admin? do
          {:error, :cannot_delete_admin}
        else
          Repo.delete(user)
        end
    end
  end

  # Private helpers - business rules encapsulated
  defp validate_business_rules(changeset) do
    changeset
    |> validate_unique_email()
    |> validate_password_strength()
  end

  defp validate_unique_email(changeset) do
    # Custom validation logic
    changeset
  end

  defp validate_password_strength(changeset) do
    # Complex password rules
    changeset
  end

  defp maybe_send_welcome_email({:ok, user}) do
    # Send email asynchronously
    Task.start(fn -> send_welcome_email(user) end)
  end

  defp maybe_send_welcome_email(error), do: error

  defp send_welcome_email(_user) do
    # Email logic
  end
end
