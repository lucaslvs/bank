defmodule BankWeb.V1.TransactionView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop

  def render("index.json", %{transactions_page: transactions_page}) do
    %{
      transactions: render_many(transactions_page.entries, __MODULE__, "transaction.json"),
      page_number: transactions_page.page_number,
      page_size: transactions_page.page_size,
      total_amount: transactions_page.total_amount,
      total_transactions: transactions_page.total_entries,
      total_pages: transactions_page.total_pages
    }
  end

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
