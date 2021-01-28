defmodule BankWeb.V1.UserView do
  @moduledoc false

  use BankWeb, :view

  alias BankWeb.V1.{AccountView, UserView}

  def render("index.json", %{users: users}) do
    %{users: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      account: render_one(user.account, AccountView, "account.json"),
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
