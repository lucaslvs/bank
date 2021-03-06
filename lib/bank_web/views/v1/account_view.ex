defmodule BankWeb.V1.AccountView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop

  alias BankWeb.V1.{TransactionView, UserView}

  def render("create.json", %{account: account, user: user}) do
    %{
      account: render_one(account, __MODULE__, "account.json"),
      user: render_one(user, UserView, "user.json")
    }
  end

  def render("show.json", %{account: account}) do
    %{account: render_one(account, __MODULE__, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      number: account.number,
      balance: Money.to_string(account.balance),
      user_id: account.user_id,
      inserted_at: NaiveDateTime.to_string(account.inserted_at),
      updated_at: NaiveDateTime.to_string(account.updated_at)
    }
  end

  def render("transfer.json", params) do
    %{
      source: render("withdraw.json", params),
      target: render("deposit.json", params)
    }
  end

  def render("withdraw.json", %{withdrawal_account: account, withdrawal_transaction: transaction}) do
    %{
      account: render_one(account, __MODULE__, "account.json"),
      transaction: render_one(transaction, TransactionView, "transaction.json")
    }
  end

  def render("deposit.json", %{deposit_account: account, deposit_transaction: transaction}) do
    %{
      account: render_one(account, __MODULE__, "account.json"),
      transaction: render_one(transaction, TransactionView, "transaction.json")
    }
  end
end
