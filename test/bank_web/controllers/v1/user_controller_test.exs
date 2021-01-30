defmodule BankWeb.V1.UserControllerTest do
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

    {:ok, user: user, account: account, conn: conn}
  end

  describe "create user" do
    @valid_email "user@email.com"
    @valid_password "123456"

    @valid_params %{
      name: "User",
      email: @valid_email,
      email_confirmation: @valid_email,
      password: @valid_password,
      password_confirmation: @valid_password,
      account: %{number: "654321", balance: 100_000}
    }

    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :create), user: @valid_params)

      assert %{
               "name" => "User",
               "email" => @valid_email,
               "account" => %{"number" => "654321", "balance" => "R$ 1,000.00"}
             } = json_response(conn, 201)["user"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :create), user: Map.new())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show user" do
    test "Renders user when the given id is valid", %{conn: conn, user: user} do
      conn = get(conn, Routes.api_v1_user_path(conn, :show, user.id))
      user_received = json_response(conn, 200)["user"]

      assert user_received["id"] == user.id
      assert user_received["name"] == user.name
      assert user_received["email"] == user.email
      assert %{} = user_received["account"]
    end

    test "Renders :not_found status when the given id is invalid", %{conn: conn, user: user} do
      conn = get(conn, Routes.api_v1_user_path(conn, :show, user.id + 1))

      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end

    test "Renders :unauthorized status when the JWT token isn't in headers", %{
      conn: conn,
      user: user
    } do
      conn =
        conn
        |> delete_req_header("authorization")
        |> get(Routes.api_v1_user_path(conn, :show, user.id))

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthenticated"}}
    end
  end
end
