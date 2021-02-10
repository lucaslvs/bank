defmodule Bank.Financial do
  @moduledoc """
  The Financial context.
  """

  import Ecto.Query, warn: false
  import Money.Sigils

  alias Bank.Financial.Operation.{Deposit, LockAccountByNumber, Transfer, Withdraw}
  alias Bank.Financial.Transaction
  alias Bank.Financial.Transaction.QueryBuilder
  alias Bank.Notifications
  alias Bank.Repo
  alias Ecto.Multi

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

  @spec deposit(String.t(), integer()) :: {:ok, any()} | {:error, any()}
  def deposit(account_number, amount) when is_binary(account_number) and is_integer(amount) do
    amount = Money.new(amount)

    Multi.new()
    |> Multi.merge(&lock_account_by_number(&1, :account, account_number))
    |> Multi.merge(&Deposit.build(Map.put(&1, :amount, amount)))
    |> Repo.transaction()
  end

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
