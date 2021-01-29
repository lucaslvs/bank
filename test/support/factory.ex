defmodule Bank.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Bank.Repo

  alias Bank.Customers.{Account, User}

  def user_factory do
    %User{
      name: "User",
      email: sequence(:email, &"user#{&1}@email.com"),
      password_hash: Argon2.hash_pwd_salt("123456")
    }
  end

  def account_factory(params) do
    %Account{
      number: "123456",
      balance: Money.new(100_000),
      user_id: get_user_id(params)
    }
  end

  defp get_user_id(params)

  defp get_user_id(%{user_id: user_id}) when is_integer(user_id) do
    user_id
  end

  defp get_user_id(%{user: %User{id: user_id}}) do
    user_id
  end

  defp get_user_id(_params), do: raise(":user or :user_id is required")
end
