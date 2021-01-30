defmodule BankWeb.V1.AccountControllerTest do
  use BankWeb.ConnCase

  import Bank.Factory

  alias BankWeb.Authentication.Guardian

  setup %{conn: conn} do
    user = insert(:user)
    account = insert(:account, user: user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, account: account, conn: conn}
  end

  describe "show account" do
    test "Renders account when the given id is valid", %{conn: conn, account: account} do
      conn = get(conn, Routes.api_v1_account_path(conn, :show, account.id))
      account_received = json_response(conn, 200)["account"]

      assert account_received["id"] == account.id
      assert account_received["balance"] == Money.to_string(account.balance)
      assert account_received["number"] == account.number
      assert account_received["userId"] == account.user_id
    end

    test "Renders :not_found status when the given id is invalid", %{conn: conn, account: account} do
      conn = get(conn, Routes.api_v1_account_path(conn, :show, account.id + 1))

      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end

    test "Renders :unauthorized status when the JWT token isn't in headers", %{
      conn: conn,
      account: account
    } do
      conn =
        conn
        |> delete_req_header("authorization")
        |> get(Routes.api_v1_account_path(conn, :show, account.id + 1))

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthenticated"}}
    end
  end
end
