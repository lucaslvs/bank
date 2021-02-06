defmodule BankWeb.V1.AccountController do
  @moduledoc false

  use BankWeb, :controller

  alias Bank.Customers
  alias Bank.Customers.Account
  alias Bank.Financial
  alias BankWeb.Authentication

  action_fallback BankWeb.FallbackController

  def create(conn, %{"user" => user_params, "account" => account_params}) do
    with {:ok, account_opening} <- Customers.open_account(user_params, account_params) do
      conn
      |> put_status(:created)
      |> render("create.json", account_opening)
    end
  end

  def show(conn, _params) do
    with {:ok, %Account{} = account} <- Authentication.current_token_user_account(conn) do
      render(conn, "show.json", account: account)
    end
  end

  def withdraw(conn, %{"amount" => amount}) do
    with {:ok, %Account{number: number}} <- Authentication.current_token_user_account(conn),
         {:ok, withdrawal_result} <- Financial.withdraw(number, amount) do
      render(conn, "withdraw.json", withdrawal_result)
    end
  end

  def deposit(conn, %{"amount" => amount}) do
    with {:ok, %Account{number: number}} <- Authentication.current_token_user_account(conn),
         {:ok, deposit_result} <- Financial.deposit(number, amount) do
      render(conn, "deposit.json", deposit_result)
    end
  end

  def transfer(conn, %{"target_account_number" => target_account_number, "amount" => amount}) do
    with {:ok, %Account{number: source_account_number}} <-
           Authentication.current_token_user_account(conn),
         {:ok, transfer_result} <-
           Financial.transfer(source_account_number, target_account_number, amount) do
      render(conn, "transfer.json", transfer_result)
    end
  end
end
