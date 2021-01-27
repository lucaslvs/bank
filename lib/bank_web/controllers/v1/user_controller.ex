defmodule BankWeb.V1.UserController do
  use BankWeb, :controller

  alias Bank.Customers
  alias Bank.Customers.User

  action_fallback BankWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Customers.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_v1_user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Customers.get_user!(id)
    render(conn, "show.json", user: user)
  end
end
