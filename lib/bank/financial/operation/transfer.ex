defmodule Bank.Financial.Operation.Transfer do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Operation.{Deposit, Withdraw}

  @type transfer_params() :: %{
          debit_account: Account.t(),
          credit_account: Account.t(),
          amount: Money.t()
        }

  @impl Bank.Financial.Operation
  @spec build(transfer_params()) :: Multi.t()
  def build(%{
        debit_account: %Account{} = debit_account,
        credit_account: %Account{} = credit_account,
        amount: %Money{} = amount
      }) do
    Multi.new()
    |> Multi.merge(&withdraw(&1, debit_account, amount))
    |> Multi.merge(&deposit(&1, credit_account, amount))
  end

  defp withdraw(_changes, debit_account, amount) do
    Map.new()
    |> Map.put(:account, debit_account)
    |> Map.put(:amount, amount)
    |> Withdraw.build()
  end

  defp deposit(_changes, credit_account, amount) do
    Map.new()
    |> Map.put(:account, credit_account)
    |> Map.put(:amount, amount)
    |> Deposit.build()
  end
end
