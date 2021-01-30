defmodule BankWeb.V1.UserView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop

  alias BankWeb.V1.{AccountView, UserView}

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

  def render("user_token.json", %{token: token}) do
    %{token: token}
  end
end
