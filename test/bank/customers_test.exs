defmodule Bank.CustomersTest do
  use Bank.DataCase

  import Bank.Factory

  alias Bank.Customers
  alias Bank.Customers.{Account, User}

  describe "get_user!/1" do
    setup :create_user

    test "Returns the user with given id is valid", %{user: user_expected} do
      user_received = Customers.get_user!(user_expected.id)

      assert user_expected.id == user_received.id
      assert user_expected.name == user_received.name
      assert user_expected.email == user_received.email
    end

    test "Raise a error the user with given id is invalid", %{user: user} do
      assert_raise Ecto.NoResultsError, fn ->
        Customers.get_user!(user.id + 1)
      end
    end
  end

  defp create_user(_context), do: {:ok, user: insert(:user)}

  describe "accounts" do
    @valid_attrs %{balance: 42, number: "some number"}
    @update_attrs %{balance: 43, number: "some updated number"}
    @invalid_attrs %{balance: nil, number: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Customers.create_account()

      account
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Customers.get_account!(account.id) == account
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Customers.change_account(account)
    end
  end
end
