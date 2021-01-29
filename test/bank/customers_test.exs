defmodule Bank.CustomersTest do
  use Bank.DataCase, async: true

  import Bank.Factory

  alias Bank.Customers
  alias Bank.Customers.{Account, User}

  describe "get_user!/1" do
    setup :create_user

    test "Returns the user when given id is valid", %{user: user_expected} do
      user_received = Customers.get_user!(user_expected.id)

      assert user_expected.id == user_received.id
      assert user_expected.name == user_received.name
      assert user_expected.email == user_received.email
    end

    test "Raise a error when given id is invalid", %{user: %User{id: id}} do
      assert_raise Ecto.NoResultsError, fn ->
        Customers.get_user!(id + 1)
      end
    end
  end

  describe "get_user/1" do
    setup :create_user

    test "Returns the user when the given id is valid", %{user: user_expected} do
      assert {:ok, %User{} = user_received} = Customers.get_user(user_expected.id)
      assert user_expected.id == user_received.id
      assert user_expected.name == user_received.name
      assert user_expected.email == user_received.email
    end

    test "Returns a not found error when the given id is invalid", %{user: %User{id: id}} do
      assert {:error, :not_found} = Customers.get_user(id + 1)
    end
  end

  describe "get_user_by!/1" do
    setup :create_user

    test "Returns the user when given parameters is valid", %{user: user_expected} do
      params = Map.take(user_expected, [:id, :name, :email])
      user_received = Customers.get_user_by!(params)

      assert user_expected.id == user_received.id
      assert user_expected.name == user_received.name
      assert user_expected.email == user_received.email
    end

    test "Raise a error when given parameters is invalid", %{user: %User{id: id}} do
      assert_raise Ecto.NoResultsError, fn ->
        params = Map.new(id: id + 1, name: "not exist", email: "not exist")
        Customers.get_user_by!(params)
      end
    end
  end

  describe "get_user_by/1" do
    setup :create_user

    test "Returns the user when given parameters is valid", %{user: user_expected} do
      params = Map.take(user_expected, [:id, :name, :email])

      assert {:ok, %User{} = user_received} = Customers.get_user_by(params)
      assert user_expected.id == user_received.id
      assert user_expected.name == user_received.name
      assert user_expected.email == user_received.email
    end

    test "Returns a not found error when given parameters is invalid", %{user: %User{id: id}} do
      params = Map.new(id: id + 1, name: "not exist", email: "not exist")

      assert {:error, :not_found} = Customers.get_user_by(params)
    end
  end

  defp create_user(_context), do: {:ok, user: insert(:user)}

  # describe "accounts" do
  #   @valid_attrs %{balance: 42, number: "some number"}
  #   @update_attrs %{balance: 43, number: "some updated number"}
  #   @invalid_attrs %{balance: nil, number: nil}

  #   def account_fixture(attrs \\ %{}) do
  #     {:ok, account} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Customers.create_account()

  #     account
  #   end

  #   test "get_account!/1 returns the account with given id" do
  #     account = account_fixture()
  #     assert Customers.get_account!(account.id) == account
  #   end

  #   test "change_account/1 returns a account changeset" do
  #     account = account_fixture()
  #     assert %Ecto.Changeset{} = Customers.change_account(account)
  #   end
  # end
end
