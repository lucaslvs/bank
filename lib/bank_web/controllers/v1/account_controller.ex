defmodule BankWeb.V1.AccountController do
  @moduledoc false

  use BankWeb, :controller

  alias Bank.Customers
  alias Bank.Customers.{Account, User}
  alias Bank.Financial
  alias Bank.Notifications
  alias BankWeb.Authentication.Guardian

  action_fallback BankWeb.FallbackController

  def create(conn, %{"user" => user_params, "account" => account_params}) do
    with {:ok, account_opening} <- Customers.open_account(user_params, account_params) do
      conn
      |> put_status(:created)
      |> render("create.json", account_opening)
    end
  end

  def show(conn, _params) do
    with token <- Guardian.Plug.current_token(conn),
         {:ok, %User{account: account}, _} <- Guardian.resource_from_token(token) do
      render(conn, "show.json", account: account)
    end
  end

  def withdraw(conn, %{"amount" => amount}) do
    with token <- Guardian.Plug.current_token(conn),
         {:ok, %User{account: account} = user, _} <- Guardian.resource_from_token(token),
         %Account{number: number} <- account,
         {:ok, withdrawal_result} <- Financial.withdraw(number, amount),
         %Bamboo.Email{} <- send_user_account_withdraw_email(user, amount) do
      render(conn, "withdraw.json", withdrawal_result)
    end
  end

  def deposit(conn, %{"amount" => amount}) do
    with token <- Guardian.Plug.current_token(conn),
         {:ok, %User{account: account}, _} <- Guardian.resource_from_token(token),
         %Account{number: number} <- account,
         {:ok, deposit_result} <- Financial.deposit(number, amount) do
      render(conn, "deposit.json", deposit_result)
    end
  end

  def transfer(conn, %{"source_account_number" => source_number, "amount" => amount}) do
    with token <- Guardian.Plug.current_token(conn),
         {:ok, %User{account: account}, _} <- Guardian.resource_from_token(token),
         %Account{number: origin_number} <- account,
         {:ok, transfer_result} <- Financial.transfer(origin_number, source_number, amount) do
      render(conn, "transfer.json", transfer_result)
    end
  end

  defp send_user_account_withdraw_email(user, amount) do
    Notifications.send_user_account_withdraw_email(user, Money.new(amount))
  end
end
