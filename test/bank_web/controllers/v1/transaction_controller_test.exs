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

    test "Returns a page with all existing transactions", %{account: account, conn: conn} do
      transaction = insert(:transaction, account: account)
      conn = get(conn, Routes.api_v1_transaction_path(conn, :index))

      assert %{
               "pageNumber" => 1,
               "pageSize" => 20,
               "pageTotalAmount" => "R$ 100.00",
               "totalAmount" => "R$ 100.00",
               "totalPages" => 1,
               "totalTransactions" => 1,
               "transactions" => [received_transaction]
             } = json_response(conn, 200)

      assert received_transaction["id"] == transaction.id
      assert received_transaction["accountId"] == transaction.account_id
      assert received_transaction["insertedAt"] == NaiveDateTime.to_string(transaction.inserted_at)
      assert received_transaction["updatedAt"] == NaiveDateTime.to_string(transaction.updated_at)
      assert received_transaction["type"] == to_string(transaction.type)

      if received_transaction["type"] in ["withdraw", "transfer_withdrawal"] do
        assert received_transaction["amount"] == Money.to_string(Money.neg(transaction.amount))
      else
        assert received_transaction["amount"] == Money.to_string(transaction.amount)
      end
    end

    test "Returns a number of transactions by the given page_size value filter value", %{
      account: account,
      conn: conn
    } do
      [transaction | _transactions] = insert_list(2, :transaction, account: account)
      conn = get(conn, Routes.api_v1_transaction_path(conn, :index), page_size: 1)

      assert %{
               "pageNumber" => 1,
               "pageSize" => 1,
               "pageTotalAmount" => "R$ 100.00",
               "totalAmount" => "R$ 200.00",
               "totalPages" => 2,
               "totalTransactions" => 2,
               "transactions" => [received_transaction]
             } = json_response(conn, 200)

      assert received_transaction["id"] == transaction.id
      assert received_transaction["accountId"] == transaction.account_id
      assert received_transaction["insertedAt"] == NaiveDateTime.to_string(transaction.inserted_at)
      assert received_transaction["updatedAt"] == NaiveDateTime.to_string(transaction.updated_at)
      assert received_transaction["type"] == to_string(transaction.type)

      if received_transaction["type"] in ["withdraw", "transfer_withdrawal"] do
        assert received_transaction["amount"] == Money.to_string(Money.neg(transaction.amount))
      else
        assert received_transaction["amount"] == Money.to_string(transaction.amount)
      end
    end

    test "Returns a page of transactions by the given page value filter value", %{
      account: account,
      conn: conn
    } do
      [_transaction | [transaction]] = insert_list(2, :transaction, account: account)
      conn = get(conn, Routes.api_v1_transaction_path(conn, :index), page: 2, page_size: 1)

      assert %{
               "pageNumber" => 2,
               "pageSize" => 1,
               "pageTotalAmount" => "R$ 100.00",
               "totalAmount" => "R$ 200.00",
               "totalPages" => 2,
               "totalTransactions" => 2,
               "transactions" => [received_transaction]
             } = json_response(conn, 200)

      assert received_transaction["id"] == transaction.id
      assert received_transaction["accountId"] == transaction.account_id
      assert received_transaction["insertedAt"] == NaiveDateTime.to_string(transaction.inserted_at)
      assert received_transaction["updatedAt"] == NaiveDateTime.to_string(transaction.updated_at)
      assert received_transaction["type"] == to_string(transaction.type)

      if received_transaction["type"] in ["withdraw", "transfer_withdrawal"] do
        assert received_transaction["amount"] == Money.to_string(Money.neg(transaction.amount))
      else
        assert received_transaction["amount"] == Money.to_string(transaction.amount)
      end
    end

    test "Returns a page of transactions by the given inserted_from filter value", %{
      account: account,
      conn: conn
    } do
      transaction = insert(:transaction, account: account, inserted_at: ~N[2021-03-05 00:00:00])

      insert(:transaction, account: account, inserted_at: ~N[2000-01-01 00:00:00])

      conn = get(conn, Routes.api_v1_transaction_path(conn, :index), inserted_from: "2021-03-05")

      assert %{
               "pageNumber" => 1,
               "pageSize" => 20,
               "pageTotalAmount" => "R$ 100.00",
               "totalAmount" => "R$ 100.00",
               "totalPages" => 1,
               "totalTransactions" => 1,
               "transactions" => [received_transaction]
             } = json_response(conn, 200)

      assert received_transaction["id"] == transaction.id
      assert received_transaction["accountId"] == transaction.account_id
      assert received_transaction["insertedAt"] == NaiveDateTime.to_string(transaction.inserted_at)
      assert received_transaction["updatedAt"] == NaiveDateTime.to_string(transaction.updated_at)
      assert received_transaction["type"] == to_string(transaction.type)

      if received_transaction["type"] in ["withdraw", "transfer_withdrawal"] do
        assert received_transaction["amount"] == Money.to_string(Money.neg(transaction.amount))
      else
        assert received_transaction["amount"] == Money.to_string(transaction.amount)
      end
    end

    test "Returns a page of transactions by the given inserted_until filter value", %{
      account: account,
      conn: conn
    } do
      transaction = insert(:transaction, account: account, inserted_at: ~N[2000-01-01 00:00:00])

      insert(:transaction, account: account, inserted_at: ~N[2021-03-05 00:00:00])

      conn = get(conn, Routes.api_v1_transaction_path(conn, :index), inserted_until: "2000-01-01")

      assert %{
               "pageNumber" => 1,
               "pageSize" => 20,
               "pageTotalAmount" => "R$ 100.00",
               "totalAmount" => "R$ 100.00",
               "totalPages" => 1,
               "totalTransactions" => 1,
               "transactions" => [received_transaction]
             } = json_response(conn, 200)

      assert received_transaction["id"] == transaction.id
      assert received_transaction["accountId"] == transaction.account_id
      assert received_transaction["insertedAt"] == NaiveDateTime.to_string(transaction.inserted_at)
      assert received_transaction["updatedAt"] == NaiveDateTime.to_string(transaction.updated_at)
      assert received_transaction["type"] == to_string(transaction.type)

      if received_transaction["type"] in ["withdraw", "transfer_withdrawal"] do
        assert received_transaction["amount"] == Money.to_string(Money.neg(transaction.amount))
      else
        assert received_transaction["amount"] == Money.to_string(transaction.amount)
      end
    end

    test "Returns a page of transactions by the given inserted_from and inserted_until filters value", %{
      account: account,
      conn: conn
    } do
      insert(:transaction, account: account, inserted_at: ~N[2000-01-01 00:00:00])
      insert(:transaction, account: account, inserted_at: ~N[2021-03-05 00:00:00])

      transaction = insert(:transaction, account: account, inserted_at: ~N[2012-12-12 00:00:00])
      path = Routes.api_v1_transaction_path(conn, :index)
      conn = get(conn, path, inserted_from: "2000-01-02", inserted_until: "2021-03-04")

      assert %{
               "pageNumber" => 1,
               "pageSize" => 20,
               "pageTotalAmount" => "R$ 100.00",
               "totalAmount" => "R$ 100.00",
               "totalPages" => 1,
               "totalTransactions" => 1,
               "transactions" => [received_transaction]
             } = json_response(conn, 200)

      assert received_transaction["id"] == transaction.id
      assert received_transaction["accountId"] == transaction.account_id
      assert received_transaction["insertedAt"] == NaiveDateTime.to_string(transaction.inserted_at)
      assert received_transaction["updatedAt"] == NaiveDateTime.to_string(transaction.updated_at)
      assert received_transaction["type"] == to_string(transaction.type)

      if received_transaction["type"] in ["withdraw", "transfer_withdrawal"] do
        assert received_transaction["amount"] == Money.to_string(Money.neg(transaction.amount))
      else
        assert received_transaction["amount"] == Money.to_string(transaction.amount)
      end
    end

    test "Returns a invalid date format error when the given filters has a invalid date values", %{conn: conn} do
      path = Routes.api_v1_transaction_path(conn, :index)

      conn = get(conn, path, inserted_from: "9999-99-99", inserted_until: "0000-00-00")
      assert %{"error" => %{"message" => "invalid date format"}} = json_response(conn, 422)

      conn = get(conn, path, inserted_from: "2021-02-10", inserted_until: "0000-00-00")
      assert %{"error" => %{"message" => "invalid date format"}} = json_response(conn, 422)

      conn = get(conn, path, inserted_from: "9999-99-99", inserted_until: "2021-02-10")
      assert %{"error" => %{"message" => "invalid date format"}} = json_response(conn, 422)
    end
  end
end
