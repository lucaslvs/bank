defmodule Bank.FinancialTest do
  use Bank.DataCase
  use Bamboo.Test

  import Bank.Factory
  import Money.Sigils

  alias Bank.Financial
  alias Bank.Notifications

  describe "withdraw/2" do
    setup [:create_user, :create_account]

    test "Returns an account with balance subtracted by the given amount", %{account: account} do
      assert {:ok, %{withdrawal_account: withdrawal_account}} = Financial.withdraw(account.number, 100_00)
      assert Money.equals?(withdrawal_account.balance, Money.subtract(account.balance, ~M[100_00]))
    end

    test "Returns an created transaction with amount value by the given amount", %{account: account} do
      assert {:ok, %{withdrawal_transaction: withdrawal_transaction}} = Financial.withdraw(account.number, 100_00)
      assert Money.equals?(withdrawal_transaction.amount, ~M[100_00])
    end

    test "Returns an created transaction with type :withdraw", %{account: account} do
      assert {:ok, %{withdrawal_transaction: withdrawal_transaction}} = Financial.withdraw(account.number, 100_00)
      assert withdrawal_transaction.type == :withdraw
    end

    test "Should send a email for the user account", %{account: account, user: user} do
      assert {:ok, _withdrawal_result} = Financial.withdraw(account.number, 100_00)
      assert_delivered_email Notifications.send_user_account_withdraw_email(user, ~M[100_00])
    end

    test "Returns a account error when not exist a account with number equals with the given account's number" do
      assert {:error, :account, message, _} = Financial.withdraw("000000", 100_00)
      assert message == "account with number 000000 not found"
    end

    test "Returns a insufficient balance error when the given account has the less balance than received amount", %{account: account} do
      assert {:error, :withdrawal_account, changeset, _} = Financial.withdraw(account.number, 1_000_000)
      assert %Ecto.Changeset{valid?: false, errors: errors} = changeset
      assert [balance: {"insufficient balance", []}] = errors
    end

    test "Returns a invalid balance error when the given amount is negative", %{account: account} do
      assert {:error, :withdrawal_account, changeset, _} = Financial.withdraw(account.number, -100_00)
      assert %Ecto.Changeset{valid?: false, errors: errors} = changeset
      assert [balance: {"must be greater than R$ 0.00", []}] = errors
    end

    test "Returns a invalid balance error when the given amount is zero", %{account: account} do
      assert {:error, :withdrawal_account, changeset, _} = Financial.withdraw(account.number, 0)
      assert %Ecto.Changeset{valid?: false, errors: errors} = changeset
      assert [balance: {"must be greater than R$ 0.00", []}] = errors
    end
  end

  describe "filter_transactions/0" do
    setup [:create_user, :create_account]

    test "Returns a page with empty entries when there isn't transactions" do
      assert {:ok, page} = Financial.filter_transactions()
      assert page.entries == []
      assert page.page_number == 1
      assert page.page_size == 20
      assert page.page_total_amount == "R$ 0.00"
      assert page.total_amount == "R$ 0.00"
      assert page.total_entries == 0
      assert page.total_pages == 1
    end

    test "Returns a page with all existing transactions", %{account: account} do
      transactions = insert_list(3, :transaction, account: account)

      assert {:ok, page} = Financial.filter_transactions()
      assert page.entries == transactions
      assert page.page_number == 1
      assert page.page_size == 20
      assert page.page_total_amount == "R$ 300.00"
      assert page.total_amount == "R$ 300.00"
      assert page.total_entries == 3
      assert page.total_pages == 1
    end
  end

  describe "filter_transactions/1" do
    setup [:create_user, :create_account]

    test "Returns a number of transactions by the given page_size value filter value", %{
      account: account
    } do
      [transaction | _transactions] = insert_list(2, :transaction, account: account)

      assert {:ok, page} = Financial.filter_transactions(Map.new(page_size: 1))
      assert page.entries == [transaction]
      assert page.page_number == 1
      assert page.page_size == 1
      assert page.page_total_amount == "R$ 100.00"
      assert page.total_amount == "R$ 200.00"
      assert page.total_entries == 2
      assert page.total_pages == 2
    end

    test "Returns a page of transactions by the given page value filter value", %{
      account: account
    } do
      [_transaction | transaction] = insert_list(2, :transaction, account: account)

      assert {:ok, page} = Financial.filter_transactions(Map.new(page: 2, page_size: 1))
      assert page.entries == transaction
      assert page.page_number == 2
      assert page.page_size == 1
      assert page.page_total_amount == "R$ 100.00"
      assert page.total_amount == "R$ 200.00"
      assert page.total_entries == 2
      assert page.total_pages == 2
    end

    test "Returns a page of transactions by the given inserted_from filter value", %{
      account: account
    } do
      expected_transactions =
        insert_list(2, :transaction, account: account, inserted_at: ~N[2021-03-05 00:00:00])

      insert_list(2, :transaction, account: account, inserted_at: ~N[2000-01-01 00:00:00])

      assert {:ok, page} = Financial.filter_transactions(Map.new(inserted_from: "2021-03-05"))
      assert page.entries == expected_transactions
      assert page.page_number == 1
      assert page.page_size == 20
      assert page.page_total_amount == "R$ 200.00"
      assert page.total_amount == "R$ 200.00"
      assert page.total_entries == 2
      assert page.total_pages == 1
    end

    test "Returns a page of transactions by the given inserted_until filter value", %{
      account: account
    } do
      expected_transactions =
        insert_list(2, :transaction, account: account, inserted_at: ~N[2000-01-01 00:00:00])

      insert_list(2, :transaction, account: account, inserted_at: ~N[2021-03-05 00:00:00])

      assert {:ok, page} = Financial.filter_transactions(Map.new(inserted_until: "2000-01-01"))
      assert page.entries == expected_transactions
      assert page.page_number == 1
      assert page.page_size == 20
      assert page.page_total_amount == "R$ 200.00"
      assert page.total_amount == "R$ 200.00"
      assert page.total_entries == 2
      assert page.total_pages == 1
    end

    test "Returns a page of transactions by the given inserted_from and inserted_until filters value",
         %{
           account: account
         } do
      insert(:transaction, account: account, inserted_at: ~N[2000-01-01 00:00:00])
      insert(:transaction, account: account, inserted_at: ~N[2021-03-05 00:00:00])

      transaction = insert(:transaction, account: account, inserted_at: ~N[2012-12-12 00:00:00])
      filters = Map.new(inserted_from: "2000-01-02", inserted_until: "2021-03-04")

      assert {:ok, page} = Financial.filter_transactions(filters)
      assert page.entries == [transaction]
      assert page.page_number == 1
      assert page.page_size == 20
      assert page.page_total_amount == "R$ 100.00"
      assert page.total_amount == "R$ 100.00"
      assert page.total_entries == 1
      assert page.total_pages == 1
    end

    test "Returns a invalid date format error when the given filters has a invalid date values" do
      assert {:error, "invalid date format"} =
               Financial.filter_transactions(
                 Map.new(inserted_from: "9999-99-99", inserted_until: "0000-00-00")
               )

      assert {:error, "invalid date format"} =
               Financial.filter_transactions(
                 Map.new(inserted_from: "2021-02-10", inserted_until: "0000-00-00")
               )

      assert {:error, "invalid date format"} =
               Financial.filter_transactions(
                 Map.new(inserted_from: "9999-99-99", inserted_until: "2021-02-10")
               )
    end
  end

  defp create_user(_context), do: {:ok, user: insert(:user)}

  defp create_account(%{user: user}), do: {:ok, account: insert(:account, user: user)}
end
