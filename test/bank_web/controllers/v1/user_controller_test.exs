defmodule BankWeb.V1.UserControllerTest do
  use BankWeb.ConnCase

  import Bank.Factory

  alias Bank.Customers.User
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

  # describe "authenticate user" do
  #   test "Renders token when the given email and password is valid", %{
  #     conn: conn,
  #     user: %User{id: id, name: name, email: email}
  #   } do
  #     conn =
  #       conn
  #       |> delete_req_header("authorization")
  #       |> post("/api/v1/users/authenticate", email: email, password: "123456")

  #     assert %{"token" => token} = json_response(conn, 201)
  #     assert {:ok, %User{} = user, _claims} = Guardian.resource_from_token(token)
  #     assert id == user.id
  #     assert name == user.name
  #     assert email == user.email
  #   end

  #   test "Renders :unauthorized status when the given email and password is valid", %{
  #     conn: conn
  #   } do
  #     conn =
  #       conn
  #       |> delete_req_header("authorization")
  #       |> post("/api/v1/users/authenticate", email: "wrong", password: "wrong")

  #     assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
  #   end
  # end
end
