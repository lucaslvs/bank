defmodule Bank.Financial.Operation.Withdraw do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Transaction

  @type withdraw_params() :: %{account: Account.t(), amount: Money.t()}

  @impl Bank.Financial.Operation
  @spec build(withdraw_params()) :: Multi.t()
  def build(%{account: %Account{} = account, amount: %Money{} = amount}) do
    Multi.new()
    |> Multi.update(:withdrawal_account, subtract_account_balance(account, amount))
    |> Multi.insert(:withdrawal_transaction, &create_withdrawal_transaction(&1, amount))
  end

  defp subtract_account_balance(%Account{balance: balance} = account, amount) do
    Account.changeset(account, Map.new(balance: Money.subtract(balance, amount)))
  end

  defp create_withdrawal_transaction(changes, amount) do
    changes
    |> Map.get(:withdrawal_account)
    |> Ecto.build_assoc(:transactions)
    |> Transaction.changeset(Map.new(amount: Money.neg(amount)))
  end
end
