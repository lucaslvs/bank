defmodule Bank.Notifications do
  @moduledoc false

  alias Bank.Customers.User
  alias Bank.Notifications.Mailer
  alias Bank.Notifications.UserAccountWithdrawMail

  @spec send_user_account_withdraw_email(Bank.Customers.User.t(), Money.t()) :: Bamboo.Email.t()
  def send_user_account_withdraw_email(%User{} = user, %Money{} = money) do
    user
    |> UserAccountWithdrawMail.build(money)
    |> Mailer.deliver_later()
  end
end
