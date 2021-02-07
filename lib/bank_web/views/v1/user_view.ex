defmodule BankWeb.V1.UserView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      inserted_at: NaiveDateTime.to_string(user.inserted_at),
      updated_at: NaiveDateTime.to_string(user.updated_at)
    }
  end
end
