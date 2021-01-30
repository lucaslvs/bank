defmodule BankWeb.V1.UserController do
  use BankWeb, :controller

  alias Bank.Customers
  alias Bank.Customers.User

  action_fallback BankWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Customers.open_account(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_v1_user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Customers.get_user(id) do
      render(conn, "show.json", user: user)
    end
  end

  def authenticate(conn, %{"email" => email, "password" => password}) do
    with {:ok, token, _claims} <- authenticate_user(email, password) do
      conn
      |> put_status(:created)
      |> render("user_token.json", token: token)
    end
  end
end
