defmodule Bank.FinancialTest do
  use Bank.DataCase

  import Bank.Factory

  alias Bank.Financial
  alias Bank.Financial.Transaction

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

    test "Returns a page of transactions by the given inserted_from filter value", %{account: account} do
      expected_transactions = insert_list(2, :transaction, account: account, inserted_at: ~N[2021-03-05 00:00:00])
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

    test "Returns a page of transactions by the given inserted_until filter value", %{account: account} do
      expected_transactions = insert_list(2, :transaction, account: account, inserted_at: ~N[2000-01-01 00:00:00])
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
  end

  defp create_user(_context), do: {:ok, user: insert(:user)}

  defp create_account(%{user: user}), do: {:ok, account: insert(:account, user: user)}
end
