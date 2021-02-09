defmodule Bank.Financial.Operation.Deposit do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Transaction

  @type deposit_params() :: %{account: Account.t(), amount: Money.t(), from_transfer?: boolean()}

  @impl Bank.Financial.Operation
  @spec build(deposit_params()) :: Multi.t()
  def build(%{
        account: %Account{} = account,
        amount: %Money{} = amount,
        from_transfer?: from_transfer?
      }) do
    Multi.new()
    |> Multi.update(:deposit_account, Account.deposit_changeset(account, amount))
    |> Multi.insert(:deposit_transaction, &transaction_changeset(&1, amount, from_transfer?))
  end

  def build(%{account: %Account{} = account, amount: %Money{} = amount}) do
    Multi.new()
    |> Multi.update(:deposit_account, Account.deposit_changeset(account, amount))
    |> Multi.insert(:deposit_transaction, &transaction_changeset(&1, amount))
  end

  defp transaction_changeset(changes, amount, from_transfer? \\ false) do
    type = if from_transfer?, do: :transfer_deposit, else: :deposit

    changes
    |> Map.get(:deposit_account)
    |> Ecto.build_assoc(:transactions)
    |> Transaction.changeset(Map.new(amount: amount, type: type))
  end
end
