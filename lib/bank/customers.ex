defmodule Bank.Customers do
  @moduledoc """
  The Customers context.
  """

  import Ecto.Query, warn: false

  alias Bank.Customers.{Account, User}
  alias Bank.Repo
  alias Ecto.Multi

  @doc """
  Creates a `Bank.Customers.User` and `Bank.Customers.Account` by the given `attrs`.

  ## Examples

      iex> attrs = %{
      ...>  account: %{number: "123456", balance: Money.new(0)},
      ...>  email: "user@email.com",
      ...>  email_confirmation: "user@email.com",
      ...>  name: "user",
      ...>  password: "password",
      ...>  password_confirmation: "password"
      ...> }
      %{
        account: %{balance: %Money{amount: 0, currency: :BRL}, number: "123456"},
        email: "user@email.com",
        email_confirmation: "user@email.com",
        name: "user",
        password: "password",
        password_confirmation: "password"
      }

      iex> open_account(attrs)
      {:ok, %User{}}

      iex> open_account(%{})
      {:error, %Ecto.Changeset{}}

      iex> open_account(%{field: "bad_value"})
      {:error, %Ecto.Changeset{}}
  """
  @spec open_account(map() | none(), map() | none()) :: {:ok, any()} | {:error, any()}
  def open_account(user_params \\ %{}, account_params \\ %{})
      when is_map(user_params) and is_map(account_params) do
    Multi.new()
    |> Multi.insert(:user, User.create_changeset(user_params))
    |> Multi.insert(:account, &account_changeset(Map.get(&1, :user), account_params))
    |> Repo.transaction()
  end

  @spec account_changeset(User.t(), map() | none()) :: Ecto.Changeset.t()
  def account_changeset(%User{} = user, params \\ %{}) when is_map(params) do
    user
    |> Ecto.build_assoc(:account)
    |> Account.changeset(params)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(binary() | integer()) :: User.t() | %Ecto.NoResultsError{}
  def get_user!(id) when is_integer(id) or is_binary(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:account)
  end

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(123)
      {:ok, %User{}}

      iex> get_user(456)
      {:error, :not_found}

  """
  @spec get_user(binary() | integer()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(id) when is_integer(id) or is_binary(id) do
    {:ok, get_user!(id)}
  rescue
    Ecto.NoResultsError ->
      {:error, :not_found}
  end

  @doc """
  Gets a single user by the given `attrs`.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by!(%{email: "valid@email.com"})
      %User{}

      iex> get_user_by!(%{email: "invalid@email.com"})
      ** (Ecto.NoResultsError)
  """
  @spec get_user_by!(map()) :: User.t() | %Ecto.NoResultsError{}
  def get_user_by!(attrs) when is_map(attrs) do
    User
    |> Repo.get_by!(attrs)
    |> Repo.preload(:account)
  end

  @doc """
  Gets a single user by the given `attrs`.

  ## Examples

      iex> get_user_by(%{email: "valid@email.com"})
      {:ok, %User{}}

      iex> get_user_by(%{email: "invalid@email.com"})
      {:error, :not_found}
  """
  @spec get_user_by(map()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user_by(attrs) when is_map(attrs) do
    {:ok, get_user_by!(attrs)}
  rescue
    Ecto.NoResultsError ->
      {:error, :not_found}
  end
end
