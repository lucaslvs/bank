defmodule Bank.Financial.Operation.Deposit do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Transaction

  @type deposit_params() :: %{account: Account.t(), amount: Money.t()}

  @impl Bank.Financial.Operation
  @spec build(deposit_params()) :: Multi.t()
  def build(%{account: %Account{} = account, amount: %Money{} = amount}) do
    Multi.new()
    |> Multi.update(:deposit_account, add_account_balance(account, amount))
    |> Multi.insert(:deposit_transaction, &create_deposit_transaction(&1, amount))
  end

  defp add_account_balance(%Account{balance: balance} = account, amount) do
    Account.changeset(account, Map.new(balance: Money.add(balance, amount)))
  end

  defp create_deposit_transaction(changes, amount) do
    changes
    |> Map.get(:deposit_account)
    |> Ecto.build_assoc(:transactions)
    |> Transaction.changeset(Map.new(amount: amount))
  end
end
