defmodule BankWeb.V1.AccountView do
  @moduledoc false

  use BankWeb, :view

  alias BankWeb.V1.AccountView

  def render("index.json", %{accounts: accounts}) do
    %{accounts: render_many(accounts, AccountView, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{account: render_one(account, AccountView, "account.json")}
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
end
