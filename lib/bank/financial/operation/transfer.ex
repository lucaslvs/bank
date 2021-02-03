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
    |> Multi.merge(&withdraw(&1, origin_account, amount))
    |> Multi.merge(&deposit(&1, source_account, amount))
  end

  defp withdraw(_changes, origin_account, amount) do
    Map.new()
    |> Map.put(:account, origin_account)
    |> Map.put(:amount, amount)
    |> Withdraw.build()
  end

  defp deposit(_changes, source_account, amount) do
    Map.new()
    |> Map.put(:account, source_account)
    |> Map.put(:amount, amount)
    |> Deposit.build()
  end
end
