defmodule BankWeb.V1.TransactionController do
  @moduledoc false

  use BankWeb, :controller

  alias Bank.Financial

  action_fallback BankWeb.FallbackController

  def index(conn, params) do
    with {:ok, transactions_page} <- Financial.filter_transactions(params) do
      render(conn, "index.json", transactions_page: transactions_page)
    end
  end
end
