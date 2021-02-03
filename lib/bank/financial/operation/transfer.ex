defmodule Bank.Financial.Operation.Transfer do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Operation.{Deposit, Withdraw}

  @type transfer_params() :: %{
          origin_account: Account.t(),
          source_account: Account.t(),
          amount: Money.t()
        }

  @impl Bank.Financial.Operation
  @spec build(transfer_params()) :: Multi.t()
  def build(%{
        origin_account: %Account{} = origin_account,
        source_account: %Account{} = source_account,
        amount: %Money{} = amount
      }) do
    Multi.new()
    |> Multi.merge(fn _changes -> merge_withdraw_operation(origin_account, amount) end)
    |> Multi.merge(fn _changes -> merge_deposit_operation(source_account, amount) end)
  end

  defp merge_withdraw_operation(origin_account, amount) do
    Withdraw.build(Map.new(account: origin_account, amount: amount))
  end

  defp merge_deposit_operation(source_account, amount) do
    Deposit.build(Map.new(account: source_account, amount: amount))
  end
end
