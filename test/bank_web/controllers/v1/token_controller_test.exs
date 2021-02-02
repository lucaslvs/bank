defmodule BankWeb.V1.TokenControllerTest do
  use BankWeb.ConnCase

  import Bank.Factory

  alias Bank.Customers.User
  alias BankWeb.Authentication.Guardian

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")

    user = insert(:user)
    account = insert(:account, user: user)

    {:ok, user: user, account: account, conn: conn}
  end

  describe "Creates a JWT token" do
    test "Renders token when the given email and password is valid", %{
      conn: conn,
      user: %User{id: id, name: name, email: email}
    } do
      conn = post(conn, Routes.api_v1_token_path(conn, :create), email: email, password: "123456")

      assert %{"token" => token} = json_response(conn, 201)
      assert {:ok, %User{} = user, _claims} = Guardian.resource_from_token(token)
      assert id == user.id
      assert name == user.name
      assert email == user.email
    end

    test "Renders :unauthorized status when the given email and password is valid", %{
      conn: conn
    } do
      conn =
        post(conn, Routes.api_v1_token_path(conn, :create), email: "wrong", password: "wrong")

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
    end
  end
end
