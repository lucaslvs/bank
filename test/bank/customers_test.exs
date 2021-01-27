defmodule Bank.CustomersTest do
  use Bank.DataCase

  alias Bank.Customers

  describe "users" do
    alias Bank.Customers.User

    @valid_attrs %{email: "some email", name: "some name", password_hash: "some password_hash"}
    @update_attrs %{
      email: "some updated email",
      name: "some updated name",
      password_hash: "some updated password_hash"
    }
    @invalid_attrs %{email: nil, name: nil, password_hash: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Customers.create_user()

      user
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Customers.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Customers.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.password_hash == "some password_hash"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_user(@invalid_attrs)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Customers.change_user(user)
    end
  end

  describe "accounts" do
    alias Bank.Customers.Account

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

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Customers.create_account(@valid_attrs)
      assert account.balance == 42
      assert account.number == "some number"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_account(@invalid_attrs)
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Customers.change_account(account)
    end
  end
end
