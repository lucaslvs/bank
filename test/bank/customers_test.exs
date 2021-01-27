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
end
