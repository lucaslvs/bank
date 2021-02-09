defmodule BankWeb.V1.TransactionView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop
  alias Bank.Financial.Transaction

  def render("index.json", %{transactions_page: transactions_page}) do
    %{
      transactions: render_many(transactions_page.entries, __MODULE__, "transaction.json"),
      page_number: transactions_page.page_number,
      page_size: transactions_page.page_size,
      page_total_amount: transactions_page.page_total_amount,
      total_amount: transactions_page.total_amount,
      total_transactions: transactions_page.total_entries,
      total_pages: transactions_page.total_pages
    }
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      amount: render_transaction_amount(transaction),
      account_id: transaction.account_id,
      type: transaction.type,
      inserted_at: NaiveDateTime.to_string(transaction.inserted_at),
      updated_at: NaiveDateTime.to_string(transaction.updated_at)
    }
  end

  defp render_transaction_amount(%Transaction{type: type, amount: amount}) do
    if type in [:withdraw, :transfer_withdrawal] do
      amount
      |> Money.neg()
      |> Money.to_string()
    else
      Money.to_string(amount)
    end
  end
end
