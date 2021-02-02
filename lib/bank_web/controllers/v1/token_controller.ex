defmodule BankWeb.V1.TokenController do
  use BankWeb, :controller

  alias BankWeb.Authentication

  action_fallback BankWeb.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    with {:ok, token, _claims} <- Authentication.authenticate_user(email, password) do
      conn
      |> put_status(:created)
      |> render("token.json", token: token)
    end
  end
end
