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

  defp create_user(_context), do: {:ok, user: insert(:user)}

  defp create_account(%{user: user}), do: {:ok, account: insert(:account, user: user)}
end
