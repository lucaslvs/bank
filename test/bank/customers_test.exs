defmodule Bank.CustomersTest do
  use Bank.DataCase, async: true

  import Bank.Factory

  alias Bank.Customers
  alias Bank.Customers.{Account, User}

  setup [:create_user, :create_account]

  describe "open_account/0" do
    test "Returns a Changeset invalid when there aren't parameters" do
      assert {:error, :user, %Ecto.Changeset{valid?: false}, %{}} = Customers.open_account()
    end
  end

  describe "open_account/1" do
    @valid_email "user@email.com"
    @valid_password "123456"

    @user_valid_params %{
      name: "User",
      email: @valid_email,
      email_confirmation: @valid_email,
      password: @valid_password,
      password_confirmation: @valid_password
    }

    test "Returns a Changeset invalid when only valid parameters is from user" do
      account_opening = Customers.open_account(@user_valid_params)

      assert {:error, :account, %Ecto.Changeset{valid?: false}, %{user: user}} = account_opening
      assert %User{} = user
      assert user.name == "User"
      assert user.email == @valid_email
      assert Argon2.check_pass(user, @valid_password)
    end

    test "Returns a Changeset invalid when the given parameters is empty" do
      account_opening = Customers.open_account(Map.new())

      assert {:error, :user, %Ecto.Changeset{valid?: false}, %{}} = account_opening
    end
  end

  describe "open_account/2" do
    @valid_email "user@email.com"
    @valid_password "123456"

    @user_valid_params %{
      name: "User",
      email: @valid_email,
      email_confirmation: @valid_email,
      password: @valid_password,
      password_confirmation: @valid_password
    }

    @account_valid_params %{number: "654321", balance: 100_000}

    test "Returns a user and account when the given parameters is valid" do
      account_opening = Customers.open_account(@user_valid_params, @account_valid_params)

      assert {:ok, %{account: %Account{} = account, user: %User{} = user}} = account_opening
      assert user.name == "User"
      assert user.email == @valid_email
      assert Argon2.check_pass(user, @valid_password)
      assert account.user_id == user.id
      assert account.number == "654321"
      assert account.balance == %Money{amount: 100_000, currency: :BRL}
    end

    test "Returns a Changeset invalid when the given parameters is empty" do
      account_opening = Customers.open_account(Map.new())

      assert {:error, :user, %Ecto.Changeset{valid?: false}, %{}} = account_opening
    end
  end

  describe "account_changeset/1" do
    test "Returns a invalid changeset when the parameters are empty", %{user: user} do
      assert %Ecto.Changeset{valid?: false} = Customers.account_changeset(user)
    end
  end

  describe "account_changeset/2" do
    @valid_params %{number: "654321", balance: 100_000}

    test "Returns a invalid changeset when the account parameters are empty", %{user: user} do
      assert %Ecto.Changeset{valid?: false} = Customers.account_changeset(user, Map.new())
    end

    test "Returns a valid changeset when the account parameters are valid", %{user: user} do
      assert %Ecto.Changeset{valid?: true} = Customers.account_changeset(user, @valid_params)
    end
  end

  describe "get_user!/1" do
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

  defp create_account(%{user: user}), do: {:ok, account: insert(:account, user: user)}
end
