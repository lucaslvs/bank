defmodule Bank.Notifications.UserAccountWithdrawEmail do
  @moduledoc false

  use Bank.Notifications.Email, :sendgrid

  alias Bank.Customers.User

  @from_email "contact@bank.com"
  @subject "Saque realizado"

  @impl Bank.Notifications.Email
  @spec build(User.t(), Money.t()) :: Bamboo.Email.t()
  def build(%User{name: name, email: email}, %Money{} = money) do
    text_body = message(name, money)

    new_email()
    |> to(email)
    |> from(@from_email)
    |> subject(@subject)
    |> text_body(text_body)
  end

  defp message(name, money) do
    """
    Olá, #{name}!

    Seu saque foi realizado com sucesso no valor de #{Money.to_string(money)}.
    """
  end
end
