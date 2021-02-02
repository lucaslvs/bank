defmodule BankWeb.V1.TokenView do
  # coveralls-ignore-start
  use BankWeb, :view
  # coveralls-ignore-stop

  def render("token.json", %{token: token}) do
    %{token: token}
  end
end
