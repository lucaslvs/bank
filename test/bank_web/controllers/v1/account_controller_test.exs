defmodule BankWeb.V1.AccountControllerTest do
  use BankWeb.ConnCase

  alias Bank.Customers
  alias Bank.Customers.Account

  @create_attrs %{
    balance: 42,
    number: "some number"
  }
  @update_attrs %{
    balance: 43,
    number: "some updated number"
  }
  @invalid_attrs %{balance: nil, number: nil}

  def fixture(:account) do
    {:ok, account} = Customers.create_account(@create_attrs)
    account
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.api_v1_account_path(conn, :show, id))

      assert %{
               "id" => id,
               "balance" => 42,
               "number" => "some number"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_account_path(conn, :create), account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_account(_) do
    account = fixture(:account)
    %{account: account}
  end
end
