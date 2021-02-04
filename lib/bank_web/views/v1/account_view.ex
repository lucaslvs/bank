defmodule BankWeb.V1.AccountView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop

  alias BankWeb.V1.{UserView, TransactionView}

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
      inserted_at: account.inserted_at,
      updated_at: account.updated_at
    }
  end

  def render("withdraw.json", %{withdrawal_account: account, withdrawal_transaction: transaction}) do
    %{
      account: render_one(account, __MODULE__, "account.json"),
      transaction: render_one(transaction, TransactionView, "transaction.json")
    }
  end
end
