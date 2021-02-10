defmodule BankWeb.V1.TransactionControllerTest do
  use BankWeb.ConnCase

  import Bank.Factory
  import Plug.BasicAuth, only: [encode_basic_auth: 2]

  setup %{conn: conn} do
    user = insert(:user)
    account = insert(:account, user: user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", encode_basic_auth("bank", "password"))

    {:ok, account: account, conn: conn}
  end

  describe "filter transactions" do
    test "Returns a page with empty entries when there isn't transactions", %{conn: conn} do
      conn = get(conn, Routes.api_v1_transaction_path(conn, :index))

      assert %{
               "pageNumber" => 1,
               "pageSize" => 20,
               "pageTotalAmount" => "R$ 0.00",
               "totalAmount" => "R$ 0.00",
               "totalPages" => 1,
               "totalTransactions" => 0,
               "transactions" => []
             } = json_response(conn, 200)
    end
  end
end
