defmodule Bank.Financial do
  @moduledoc """
  The Financial context.
  """

  import Ecto.Query, warn: false

  alias Bank.Customers.Account

  alias Bank.Financial.Operation.{Deposit, LockAccountByNumber, Transfer, Withdraw}
  alias Bank.Financial.Transaction
  alias Bank.Notifications
  alias Bank.Repo
  alias Ecto.Multi

  @spec transfer(String.t(), String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def transfer(origin_account_number, source_account_number, amount)
      when is_binary(origin_account_number) and is_binary(source_account_number) and
             is_integer(amount) do
    Multi.new()
    |> Multi.merge(&lock_account_by_number(&1, :origin_account, origin_account_number))
    |> Multi.merge(&lock_account_by_number(&1, :source_account, source_account_number))
    |> Multi.merge(&Transfer.build(Map.put(&1, :amount, Money.new(amount))))
    |> Repo.transaction()
  end

  @spec withdraw(String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def withdraw(account_number, amount) when is_binary(account_number) and is_integer(amount) do
    amount = Money.new(amount)

    withdrawal_result =
      Multi.new()
      |> Multi.merge(&lock_account_by_number(&1, :account, account_number))
      |> Multi.merge(&Withdraw.build(Map.put(&1, :amount, amount)))
      |> Repo.transaction()

    case withdrawal_result do
      {:ok, %{withdrawal_account: account}} ->
        account
        |> Repo.preload(:user)
        |> Map.get(:user)
        |> Notifications.send_user_account_withdraw_email(amount)

      withdrawal_result ->
        withdrawal_result
    end
  end

  @spec deposit(String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def deposit(account_number, amount) when is_binary(account_number) and is_integer(amount) do
    Multi.new()
    |> Multi.merge(&lock_account_by_number(&1, :account, account_number))
    |> Multi.merge(&Deposit.build(Map.put(&1, :amount, Money.new(amount))))
    |> Repo.transaction()
  end

  defp lock_account_by_number(changes, key, number) do
    changes
    |> Map.put(:key, key)
    |> Map.put(:number, number)
    |> LockAccountByNumber.build()
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(%Account{} = account, attrs \\ %{}) do
    account
    |> Ecto.build_assoc(:transaction)
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
