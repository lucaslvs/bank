defmodule Bank.Communications do
  @moduledoc false

  alias Bank.Communications.Mailer
  alias Bank.Communications.UserAccountWithdrawMail
  alias Bank.Customers.User

  @spec send_user_account_withdraw_email(Bank.Customers.User.t(), Money.t()) :: Bamboo.Email.t()
  def send_user_account_withdraw_email(%User{} = user, %Money{} = money) do
    user
    |> UserAccountWithdrawMail.build(money)
    |> Mailer.deliver_later()
  end
end
