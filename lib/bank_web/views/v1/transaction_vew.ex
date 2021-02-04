defmodule BankWeb.V1.TransactionView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      balance: Money.to_string(transaction.amount),
      account_id: transaction.account_id,
      inserted_at: transaction.inserted_at,
      updated_at: transaction.updated_at
    }
  end
end
