defmodule Bank.Customers do
  @moduledoc """
  The Customers context.
  """

  import Ecto.Query, warn: false

  alias Bank.Customers.{Account, User}
  alias Bank.Repo

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(integer() | binary()) :: User.t() | %Ecto.NoResultsError{}
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
  @spec get_user(integer() | binary()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(id) when is_integer(id) or is_binary(id) do
    {:ok, get_user!(id)}
  rescue
    Ecto.NoResultsError ->
      {:error, :not_found}
  end

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
  @spec open_account(map() | none()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def open_account(attrs \\ %{}) when is_map(attrs) do
    attrs
    |> User.create_changeset()
    |> Repo.insert()
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_account!(integer() | binary()) :: Account.t() | %Ecto.NoResultsError{}
  def get_account!(id) when is_integer(id) or is_binary(id) do
    Repo.get!(Account, id)
  end

  @doc """
  Gets a single account.

  ## Examples

      iex> get_account(123)
      {:ok, %Account{}}

      iex> get_account(456)
      {:error, :not_found}

  """
  @spec get_account(integer() | binary()) :: {:ok, Account.t()} | {:error, :not_found}
  def get_account(id) when is_integer(id) or is_binary(id) do
    {:ok, get_account!(id)}
  rescue
    Ecto.NoResultsError ->
      {:error, :not_found}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  @spec change_account(Account.t(), map() | none()) :: Ecto.Changeset.t()
  def change_account(%Account{} = account, attrs \\ %{}) when is_map(attrs) do
    Account.changeset(account, attrs)
  end
end
