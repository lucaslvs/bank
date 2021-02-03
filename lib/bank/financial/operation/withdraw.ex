defmodule Bank.Financial.Operation.Withdraw do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Transaction

  @impl Bank.Financial.Operation
  @spec build(%{account: Account.t(), amount: Money.t()}) :: Multi.t()
  def build(%{account: %Account{} = account, amount: %Money{} = amount}) do
    withdrawal_transaction = &withdraw_changeset(Map.get(&1, :withdrawal_account), amount)

    Multi.new()
    |> Multi.update(:withdrawal_account, update_account_changeset(account, amount))
    |> Multi.insert(:withdrawal_transaction, withdrawal_transaction)
  end

  defp update_account_changeset(%Account{balance: balance} = account, amount) do
    Account.changeset(account, Map.new(balance: Money.subtract(balance, amount)))
  end

  defp withdraw_changeset(%Account{} = account, amount) do
    account
    |> Ecto.build_assoc(:transactions)
    |> Transaction.changeset(Map.new(amount: Money.neg(amount)))
  end
end
