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

  describe "open account" do
    @valid_email "user@email.com"
    @valid_password "123456"

    @user_valid_params %{
      name: "User",
      email: @valid_email,
      email_confirmation: @valid_email,
      password: @valid_password,
      password_confirmation: @valid_password
    }

    @account_valid_params %{number: "654321", balance: 100_000}

    test "Renders account opening when data is valid", %{conn: conn} do
      path = Routes.api_v1_account_path(conn, :create)
      conn = post(conn, path, user: @user_valid_params, account: @account_valid_params)

      assert account_opening = json_response(conn, 201)

      assert %{
               "name" => "User",
               "email" => @valid_email
             } = account_opening["user"]

      assert %{
               "number" => "654321",
               "balance" => "R$ 1,000.00"
             } = account_opening["account"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.api_v1_account_path(conn, :create), user: Map.new(), account: Map.new())

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show account" do
    test "Renders account when the given id is valid", %{conn: conn, account: account} do
      conn = get(conn, Routes.api_v1_account_path(conn, :show))
      assert account_received = json_response(conn, 200)["account"]

      assert account_received["id"] == account.id
      assert account_received["balance"] == Money.to_string(account.balance)
      assert account_received["number"] == account.number
      assert account_received["userId"] == account.user_id
    end

    test "Renders :unauthorized status when the JWT token isn't in headers", %{conn: conn} do
      conn =
        conn
        |> delete_req_header("authorization")
        |> get(Routes.api_v1_account_path(conn, :show))

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthenticated"}}
    end
  end
end
