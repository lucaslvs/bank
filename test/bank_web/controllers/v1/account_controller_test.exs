defmodule BankWeb.V1.AccountControllerTest do
  use BankWeb.ConnCase

  import Bank.Factory
  import Money.Sigils

  alias BankWeb.Authentication.Guardian

  setup %{conn: conn} do
    user = insert(:user)
    account = insert(:account, user: user)

    target_user = insert(:user, email: "target@email.com")
    target_account = insert(:account, number: "654321", user: target_user)

    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, account: account, conn: conn, target_account: target_account}
  end

  describe "create/2" do
    @valid_email "valid@email.com"
    @valid_password "123456"

    @user_valid_params %{
      name: "User",
      email: @valid_email,
      email_confirmation: @valid_email,
      password: @valid_password,
      password_confirmation: @valid_password
    }

    @account_valid_params %{number: "123123", balance: 100_000}

    test "Renders account opening when data is valid", %{conn: conn} do
      path = Routes.api_v1_account_path(conn, :create)
      conn = post(conn, path, user: @user_valid_params, account: @account_valid_params)

      assert account_opening = json_response(conn, 201)

      assert %{
               "name" => "User",
               "email" => @valid_email
             } = account_opening["user"]

      assert %{
               "number" => "123123",
               "balance" => "R$ 1,000.00"
             } = account_opening["account"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.api_v1_account_path(conn, :create), user: Map.new(), account: Map.new())

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show/2" do
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

  describe "transfer/2" do
    test "Returns an target account with balance added by the given amount", %{target_account: target_account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/transfer", target_account_number: target_account.number, amount: 100_00)

      assert transfer_result = json_response(conn, 201)
    end

    test "Returns an created target transaction with amount value by the given amount", %{target_account: target_account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/transfer", target_account_number: target_account.number, amount: 100_00)

      assert transfer_result = json_response(conn, 201)
    end

    test "Returns an created transaction with type :transfer_deposit", %{target_account: target_account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/transfer", target_account_number: target_account.number, amount: 100_00)

      assert transfer_result = json_response(conn, 201)
    end

    test "Returns an account with balance subtracted by the given amount", %{target_account: target_account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/transfer", target_account_number: target_account.number, amount: 100_00)

      assert transfer_result = json_response(conn, 201)
    end

    test "Returns an created source transaction with amount value by the given amount", %{account: account, target_account: target_account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/transfer", target_account_number: target_account.number, amount: 100_00)

      assert transfer_result = json_response(conn, 201)
    end

    test "Returns an created transaction with type :transfer_withdrawal", %{account: account, target_account: target_account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/transfer", target_account_number: target_account.number, amount: 100_00)

      assert transfer_result = json_response(conn, 201)
    end
  end

  describe "deposit/2" do
    test "Returns an account with balance added by the given amount", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/deposit", amount: 100_00)

      assert deposit_result = json_response(conn, 201)

      deposit_account = deposit_result["account"]
      account = Bank.Repo.reload!(account)

      assert deposit_account["balance"] == "R$ 1,100.00"
      assert deposit_account["id"] == account.id
      assert deposit_account["insertedAt"] == NaiveDateTime.to_string(account.inserted_at)
      assert deposit_account["number"] == account.number
      assert deposit_account["updatedAt"] == NaiveDateTime.to_string(account.updated_at)
      assert deposit_account["userId"] == account.user_id
    end

    test "Returns an created transaction with amount value by the given amount", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/deposit", amount: 100_00)

      assert deposit_result = json_response(conn, 201)

      deposit_transaction = deposit_result["transaction"]

      assert deposit_transaction["amount"] == "R$ 100.00"
      assert deposit_transaction["accountId"] == account.id
    end

    test "Returns an created transaction with type :deposit", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/deposit", amount: 100_00)

      assert deposit_result = json_response(conn, 201)

      deposit_transaction = deposit_result["transaction"]

      assert deposit_transaction["amount"] == "R$ 100.00"
      assert deposit_transaction["accountId"] == account.id
      assert deposit_transaction["type"] == "deposit"
    end

    test "Returns a invalid balance error when the given amount is negative", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/deposit", amount: -100_00)

      assert %{"errors" => %{"depositAccount" => %{"balance" => ["must be greater than R$ 0.00"]}}} = json_response(conn, 422)
    end

    test "Returns a invalid balance error when the given amount is zero", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/deposit", amount: 0)

      assert %{"errors" => %{"depositAccount" => %{"balance" => ["must be greater than R$ 0.00"]}}} = json_response(conn, 422)
    end
  end

  describe "withdraw/2" do
    test "Returns an account with balance subtracted by the given amount", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/withdraw", amount: 100_00)

      assert withdrawal_result = json_response(conn, 201)

      withdrawal_account = withdrawal_result["account"]
      account = Bank.Repo.reload!(account)

      assert withdrawal_account["balance"] == "R$ 900.00"
      assert withdrawal_account["id"] == account.id
      assert withdrawal_account["insertedAt"] == NaiveDateTime.to_string(account.inserted_at)
      assert withdrawal_account["number"] == account.number
      assert withdrawal_account["updatedAt"] == NaiveDateTime.to_string(account.updated_at)
      assert withdrawal_account["userId"] == account.user_id
    end

    test "Returns an created transaction with amount value by the given amount", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/withdraw", amount: 100_00)

      assert withdrawal_result = json_response(conn, 201)

      withdrawal_transaction = withdrawal_result["transaction"]

      assert withdrawal_transaction["amount"] == "R$ -100.00"
      assert withdrawal_transaction["accountId"] == account.id
    end

    test "Returns an created transaction with type :withdraw", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/withdraw", amount: 100_00)

      assert withdrawal_result = json_response(conn, 201)

      withdrawal_transaction = withdrawal_result["transaction"]

      assert withdrawal_transaction["amount"] == "R$ -100.00"
      assert withdrawal_transaction["accountId"] == account.id
      assert withdrawal_transaction["type"] == "withdraw"
    end

    test "Returns a invalid balance error when the given amount is negative", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/withdraw", amount: -100_00)

      assert %{"errors" => %{"withdrawalAccount" => %{"balance" => ["must be greater than R$ 0.00"]}}} = json_response(conn, 422)
    end

    test "Returns a insufficient balance error when the given account has the less balance than received amount", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/withdraw", amount: 1_000_000)

      assert %{"errors" => %{"withdrawalAccount" => %{"balance" => ["insufficient balance"]}}} = json_response(conn, 422)
    end

    test "Returns a invalid balance error when the given amount is zero", %{account: account, conn: conn} do
      conn = post(conn, "/api/v1/accounts/withdraw", amount: 0)

      assert %{"errors" => %{"withdrawalAccount" => %{"balance" => ["must be greater than R$ 0.00"]}}} = json_response(conn, 422)
    end
  end
end
