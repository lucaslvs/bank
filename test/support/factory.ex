defmodule Bank.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Bank.Repo

  import Money.Sigils

  alias Bank.Customers.{Account, User}
  alias Bank.Financial.Transaction

  def user_factory do
    %User{
      name: "User",
      email: sequence(:email, &"user#{&1}@email.com"),
      password_hash: Argon2.hash_pwd_salt("123456")
    }
  end

  def account_factory(params) do
    %Account{
      number: Map.get(params, :number, "123456"),
      balance: Money.new(100_000),
      user_id: get_user_id(params)
    }
  end

  def transaction_factory(params) do
    %Transaction{
      amount: ~M[10_000],
      account_id: get_account_id(params),
      type: get_type(params),
      inserted_at: get_inserted_at(params)
    }
  end

  defp get_type(params) do
    types = [:withdraw, :deposit, :transfer_deposit, :transfer_withdrawal]

    Map.get(params, :type, sequence(:type, types))
  end

  defp get_inserted_at(%{inserted_at: %NaiveDateTime{} = inserted_at}) do
    NaiveDateTime.truncate(inserted_at, :second)
  end

  defp get_inserted_at(_params) do
    NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
  end

  defp get_account_id(params)

  defp get_account_id(%{account: %Account{id: account_id}}), do: account_id

  defp get_account_id(_params), do: raise(":account is required")

  defp get_user_id(params)

  defp get_user_id(%{user: %User{id: user_id}}), do: user_id

  defp get_user_id(_params), do: raise(":user is required")
end
