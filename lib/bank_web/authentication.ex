defmodule BankWeb.Authentication do
  @moduledoc false

  alias Bank.Customers
  alias Bank.Customers.{Account, User}
  alias BankWeb.Authentication.Guardian

  @doc """
  Authenticate user by the given `email` and `password`.

  Will returns a `Guardian.Token.token()` and `Guardian.Token.claims()`, If `email` and `password` is valid.
  """
  @spec authenticate_user(binary(), binary()) ::
          {:ok, Guardian.Token.token(), Guardian.Token.claims()}
          | {:error, any()}
          | {:error, :unauthorized}
  def authenticate_user(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, %User{} = user} <- Customers.get_user_by(%{email: email}),
         true <- is_valid_user_password?(user, password) do
      Guardian.encode_and_sign(user)
    else
      {:error, :not_found} ->
        Argon2.no_user_verify()
        {:error, :unauthorized}

      false ->
        {:error, :unauthorized}
    end
  end

  defp is_valid_user_password?(%User{password_hash: password_hash}, password) do
    Argon2.verify_pass(password, password_hash)
  end

  @spec current_token_user_account(Plug.Conn.t()) :: {:error, :unauthorized} | {:ok, Account.t()}
  def current_token_user_account(%Plug.Conn{
        private: %{guardian_default_resource: %User{account: account}}
      }) do
    {:ok, account}
  end

  def current_token_user_account(_conn), do: {:error, :unauthorized}
end
