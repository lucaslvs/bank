defmodule BankWeb.V1.TransactionController do
  @moduledoc false

  use BankWeb, :controller

  alias Bank.Financial

  action_fallback BankWeb.FallbackController

  def index(conn, params) do
    transactions_page = Financial.filter_transactions(params)
    render(conn, "index.json", transactions_page: transactions_page)
  end
end
