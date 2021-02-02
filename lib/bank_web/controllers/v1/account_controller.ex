defmodule BankWeb.V1.AccountController do
  @moduledoc false

  use BankWeb, :controller

  alias Bank.Customers
  alias Bank.Customers.Account

  action_fallback BankWeb.FallbackController

  def create(conn, %{"user" => user_params, "account" => account_params}) do
    with {:ok, account_opening} <- Customers.open_account(user_params, account_params) do
      conn
      |> put_status(:created)
      |> render("create.json", account_opening)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %Account{} = account} <- Customers.get_account(id) do
      render(conn, "show.json", account: account)
    end
  end
end
