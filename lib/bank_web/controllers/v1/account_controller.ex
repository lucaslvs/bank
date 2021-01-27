defmodule BankWeb.V1.AccountController do
  use BankWeb, :controller

  alias Bank.Customers
  alias Bank.Customers.Account

  action_fallback BankWeb.FallbackController

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Customers.create_account(account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_v1_account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Customers.get_account!(id)
    render(conn, "show.json", account: account)
  end
end
