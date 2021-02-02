defmodule Bank.FinancialTest do
  use Bank.DataCase

  alias Bank.Financial

  describe "transactions" do
    alias Bank.Financial.Transaction

    @valid_attrs %{amount: 42}
    @update_attrs %{amount: 43}
    @invalid_attrs %{amount: nil}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Financial.create_transaction()

      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Financial.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Financial.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} = Financial.create_transaction(@valid_attrs)
      assert transaction.amount == 42
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Financial.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{} = transaction} = Financial.update_transaction(transaction, @update_attrs)
      assert transaction.amount == 43
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Financial.update_transaction(transaction, @invalid_attrs)
      assert transaction == Financial.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Financial.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Financial.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Financial.change_transaction(transaction)
    end
  end
end
