defmodule BankWeb.V1.UserView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  def render("user_token.json", %{token: token}) do
    %{token: token}
  end
end
