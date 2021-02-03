defmodule Bank.Financial.Operation.Withdraw do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Transaction

  @impl Bank.Financial.Operation
  @spec build(%{account: Account.t(), amount: Money.t()}) :: Multi.t()
  def build(%{account: %Account{} = account, amount: %Money{} = amount}) do
    Multi.new()
    |> Multi.update(:withdrawal_account, update_account_balance(account, amount))
    |> Multi.insert(:withdrawal_transaction, &create_transaction(&1, amount))
  end

  defp update_account_balance(%Account{balance: balance} = account, amount) do
    Account.changeset(account, Map.new(balance: Money.subtract(balance, amount)))
  end

  defp create_transaction(changes, amount) do
    changes
    |> Map.get(:withdrawal_account)
    |> Ecto.build_assoc(:transactions)
    |> Transaction.changeset(Map.new(amount: Money.neg(amount)))
  end
end
