defmodule BankWeb.V1.UserController do
  use BankWeb, :controller

  action_fallback BankWeb.FallbackController

  def authenticate(conn, %{"email" => email, "password" => password}) do
    with {:ok, token, _claims} <- authenticate_user(email, password) do
      conn
      |> put_status(:created)
      |> render("user_token.json", token: token)
    end
  end
end
