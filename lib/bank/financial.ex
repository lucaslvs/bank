defmodule Bank.Financial do
  @moduledoc """
  The Financial context.
  """

  import Ecto.Query, warn: false

  alias Bank.Financial.Operation.{Deposit, LockAccountByNumber, Transfer, Withdraw}
  alias Bank.Financial.Transaction
  alias Bank.Notifications
  alias Bank.Repo
  alias Ecto.Multi

  @spec transfer(String.t(), String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def transfer(debit_account_number, credit_account_number, amount)
      when is_binary(debit_account_number) and is_binary(credit_account_number) and
             is_integer(amount) do
    amount = Money.new(amount)

    Multi.new()
    |> Multi.merge(&lock_account_by_number(&1, :debit_account, debit_account_number))
    |> Multi.merge(&lock_account_by_number(&1, :credit_account, credit_account_number))
    |> Multi.merge(&Transfer.build(Map.put(&1, :amount, amount)))
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

        withdrawal_result

      withdrawal_result ->
        withdrawal_result
    end
  end

  @spec deposit(String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def deposit(account_number, amount) when is_binary(account_number) and is_integer(amount) do
    amount = Money.new(amount)

    Multi.new()
    |> Multi.merge(&lock_account_by_number(&1, :account, account_number))
    |> Multi.merge(&Deposit.build(Map.put(&1, :amount, amount)))
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
end
