defmodule BankWeb.V1.AccountController do
  @moduledoc false

  use BankWeb, :controller

  alias Bank.Customers
  alias Bank.Customers.Account

  action_fallback BankWeb.FallbackController

  def show(conn, %{"id" => id}) do
    with {:ok, %Account{} = account} <- Customers.get_account(id) do
      render(conn, "show.json", account: account)
    end
  end
end
