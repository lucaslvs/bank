defmodule Bank.Financial.Operation.Transfer do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account
  alias Bank.Financial.Operation.{Deposit, Withdraw}

  @type transfer_params() :: %{
          source_account: Account.t(),
          target_account: Account.t(),
          amount: Money.t()
        }

  @impl Bank.Financial.Operation
  @spec build(transfer_params()) :: Multi.t()
  def build(%{
        source_account: %Account{} = source_account,
        target_account: %Account{} = target_account,
        amount: %Money{} = amount
      }) do
    Multi.new()
    |> Multi.run(:validation, &validate_transfer(&1, &2, source_account, target_account))
    |> Multi.merge(&withdraw(&1, source_account, amount))
    |> Multi.merge(&deposit(&1, target_account, amount))
  end

  defp validate_transfer(_, _, source_account, target_account) do
    changeset = Account.transfer_changeset(source_account, target_account)

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

  defp withdraw(_changes, source_account, amount) do
    Map.new()
    |> Map.put(:account, source_account)
    |> Map.put(:amount, amount)
    |> Withdraw.build()
  end

  defp deposit(_changes, target_account, amount) do
    Map.new()
    |> Map.put(:account, target_account)
    |> Map.put(:amount, amount)
    |> Deposit.build()
  end
end
