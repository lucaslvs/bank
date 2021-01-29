defmodule Bank.Communications.UserAccountWithdrawMail do
  @moduledoc false

  use Bank.Communications.Mail, :sendgrid

  alias Bank.Customers.User

  @impl Bank.Communications.Mail
  @spec build(User.t(), Money.t()) :: Bamboo.Email.t()
  def build(%User{name: name, email: email}, %Money{} = money) do
    text_body = message(name, money)

    new_email()
    |> to(email)
    |> from("contact@bank.com")
    |> subject("Saque realizado")
    |> text_body(text_body)
  end

  defp message(name, money) do
    """
    Olá, #{name}!

    Seu saque foi realizado com sucesso no valor de #{formated_money(money)}.
    """
  end

  defp formated_money(money), do: Money.to_string(money)
end
