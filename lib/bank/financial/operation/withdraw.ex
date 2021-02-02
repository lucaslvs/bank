defmodule Bank.Financial.Operation.Withdraw do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Transaction

  @impl Bank.Financial.Operation
  @spec build(%{account: Account.t(), amount: Money.t()}) :: Multi.t()
  def build(%{account: %Account{} = account, amount: %Money{} = amount}) do
    withdraw_transaction = &withdraw_changeset(Map.get(&1, :account_withdraw), amount)

    Multi.new()
    |> Multi.update(:account_withdraw, update_account_changeset(account, amount))
    |> Multi.insert(:withdraw_transaction, withdraw_transaction)
  end

  defp update_account_changeset(%Account{balance: balance} = account, amount) do
    Account.changeset(account, Map.new(balance: Money.subtract(balance, amount)))
  end

  defp withdraw_changeset(%Account{} = account, amount) do
    account
    |> Ecto.build_assoc(:transactions)
    |> Transaction.changeset(Map.new(amount: amount))
  end
end
