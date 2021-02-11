defmodule Bank.Financial do
  @moduledoc """
  The Financial context is responsible for providing an API of the
  business logic of account's operation and your transactions.
  """

  import Ecto.Query, warn: false
  import Money.Sigils

  alias Bank.Financial.Operation.{Deposit, LockAccountByNumber, Transfer, Withdraw}
  alias Bank.Financial.Transaction
  alias Bank.Financial.Transaction.QueryBuilder
  alias Bank.Notifications
  alias Bank.Repo
  alias Ecto.Multi

  @doc """
  Performs a `Bank.Financial.Operation.Transfer.build/1`
  on the provided `Bank.Customers.Account.t()` `source_account_number` and
  `Bank.Customers.Account.t()` `target_account_number`. This operation will perform
  a `Bank.Financial.Operation.Withdraw.build/1` operation on the `target_account_number` and then
  perform a `Bank.Financial.Operation.Deposit.build/1` operation on the `source_account_number`,
  these operations are done in the same database transaction to avoid inconsistent results in case
  of a failure in one of the operations. `Bank.Financial.Operation.Transfer.build/1` operations are also
  performed with a lock on both accounts records at the same time to prevent issues
  while calculating the final accounts balances.
  """
  @spec transfer(String.t(), String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def transfer(source_account_number, target_account_number, amount)
      when is_binary(source_account_number) and is_binary(target_account_number) and
             is_integer(amount) do
    amount = Money.new(amount)

    Multi.new()
    |> Multi.merge(&lock_account_by_number(&1, :source_account, source_account_number))
    |> Multi.merge(&lock_account_by_number(&1, :target_account, target_account_number))
    |> Multi.merge(&Transfer.build(Map.put(&1, :amount, amount)))
    |> Repo.transaction()
  end

  @doc """
  Performs a `Bank.Financial.Operation.Deposit.build/1` operation on the provided
  `Bank.Customers.Account.t()` `:number`. This operation will add a new `Bank.Financial.Transaction`
  to the `Bank.Customers.Account.t()` and then recalculate the `Bank.Customers.Account.t()` `:balance`
  adding the `amount` to it. Deposit operations are performed with a lock in the `Bank.Customers.Account.t()`
  record to prevent issues while calculating the final `Bank.Customers.Account.t()` `:balance`.
  """
  @spec deposit(String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def deposit(account_number, amount) when is_binary(account_number) and is_integer(amount) do
    amount = Money.new(amount)

    Multi.new()
    |> Multi.merge(&lock_account_by_number(&1, :account, account_number))
    |> Multi.merge(&Deposit.build(Map.put(&1, :amount, amount)))
    |> Repo.transaction()
  end

  @doc """
  Performs a `Bank.Financial.Operation.Withdraw.build/1` operation on the provided
  `Bank.Customers.Account.t()` `:number`. This operation will add a new `Bank.Financial.Transaction`
  to the `Bank.Customers.Account.t()` and then recalculate the `Bank.Customers.Account.t()` `:balance`
  subtracting the `amount` to it. Withdraw operations are performed with a lock in the `Bank.Customers.Account.t()`
  record to prevent issues while calculating the final `Bank.Customers.Account.t()` `:balance`.
  """
  @spec withdraw(String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def withdraw(account_number, amount) when is_binary(account_number) and is_integer(amount) do
    amount = Money.new(amount)

    Multi.new()
    |> Multi.merge(&lock_account_by_number(&1, :account, account_number))
    |> Multi.merge(&Withdraw.build(Map.put(&1, :amount, amount)))
    |> Repo.transaction()
    |> maybe_notify_successful_withdrawal()
  end

  defp maybe_notify_successful_withdrawal(withdrawal_result) do
    case withdrawal_result do
      {:ok, %{withdrawal_account: account, withdrawal_transaction: %Transaction{amount: amount}}} ->
        account
        |> Repo.preload(:user)
        |> Map.get(:user)
        |> Notifications.send_user_account_withdraw_email(Money.abs(amount))

        withdrawal_result

      withdrawal_result ->
        withdrawal_result
    end
  end

  defp lock_account_by_number(changes, key, number) do
    changes
    |> Map.put(:key, key)
    |> Map.put(:number, number)
    |> LockAccountByNumber.build()
  end

  @doc """
  Returns a filtered page with all the `Bank.Financial.Transaction` created by following parameters:

  - :page - the number of the page.
  - :page_size - The size of the transactions list.
  - :inserted_from - The date to filter all transactions that were created on and after this date.
  - :inserted_until - The date to filter all transactions that were created on and before this date.
  """
  @spec filter_transactions(map()) :: {:ok, map()} | {:error, binary()}
  def filter_transactions(params \\ %{}) when is_map(params) do
    with params when is_map(params) <- parse_inserted_filters(params),
         query <- QueryBuilder.filter(params),
         total_amount <- Repo.aggregate(query, :sum, :amount),
         transactions_page <- Repo.paginate(query, params) do
      total_amount =
        if is_nil(total_amount) do
          Money.to_string(~M[0])
        else
          Money.to_string(total_amount)
        end

      transactions_page =
        transactions_page
        |> calculate_page_total_amount()
        |> Map.put(:total_amount, total_amount)

      {:ok, transactions_page}
    end
  rescue
    MatchError ->
      {:error, "invalid date format"}

    _ ->
      {:error, "invalid parameters"}
  end

  defp parse_inserted_filters(params)
       when is_map_key(params, "inserted_from") and is_map_key(params, "inserted_until") do
    params
    |> Map.update!("inserted_from", &parse_date/1)
    |> Map.update!("inserted_until", &parse_date/1)
  end

  defp parse_inserted_filters(params)
       when is_map_key(params, :inserted_from) and is_map_key(params, :inserted_until) do
    params
    |> Map.update!(:inserted_from, &parse_date/1)
    |> Map.update!(:inserted_until, &parse_date/1)
  end

  defp parse_inserted_filters(params) when is_map_key(params, "inserted_from") do
    Map.update!(params, "inserted_from", &parse_date/1)
  end

  defp parse_inserted_filters(params) when is_map_key(params, :inserted_from) do
    Map.update!(params, :inserted_from, &parse_date/1)
  end

  defp parse_inserted_filters(params) when is_map_key(params, "inserted_until") do
    Map.update!(params, "inserted_until", &parse_date/1)
  end

  defp parse_inserted_filters(params) when is_map_key(params, :inserted_until) do
    Map.update!(params, :inserted_until, &parse_date/1)
  end

  defp parse_inserted_filters(params), do: params

  defp parse_date(date_string) do
    {:ok, date_erl} = Calendar.ISO.parse_date(date_string)
    Date.from_erl!(date_erl)
  end

  defp calculate_page_total_amount(%Scrivener.Page{entries: transactions} = transactions_page) do
    page_total_amount =
      transactions
      |> calculate_total_transaction_amount()
      |> Money.to_string()

    transactions_page
    |> Map.from_struct()
    |> Map.put(:page_total_amount, page_total_amount)
  end

  defp calculate_total_transaction_amount(transactions) do
    Enum.reduce(transactions, Money.new(0), &Money.add(&2, &1.amount))
  end
end
