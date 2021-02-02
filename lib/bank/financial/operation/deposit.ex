defmodule Bank.Financial.Operation.Deposit do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Transaction

  @impl Bank.Financial.Operation
  @spec build(%{account: Account.t(), amount: Money.t()}) :: Multi.t()
  def build(%{account: %Account{} = account, amount: %Money{} = amount}) do
    deposit_transaction = &deposit_changeset(Map.get(&1, :account_deposit), amount)

    Multi.new()
    |> Multi.update(:account_deposit, update_account_changeset(account, amount))
    |> Multi.insert(:deposit_transaction, deposit_transaction)
  end

  defp update_account_changeset(%Account{balance: balance} = account, amount) do
    Account.changeset(account, Map.new(balance: Money.add(balance, amount)))
  end

  defp deposit_changeset(%Account{} = account, amount) do
    account
    |> Ecto.build_assoc(:transactions)
    |> Transaction.changeset(Map.new(amount: amount))
  end
end
