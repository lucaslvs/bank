defmodule Bank.Notifications do
  @moduledoc """
  A module responsible to send all notifications from bank.
  """

  alias Bank.Customers.User
  alias Bank.Notifications.Mailer
  alias Bank.Notifications.UserAccountWithdrawEmail

  @doc """
  Send the `Bank.Notifications.UserAccountWithdrawEmail` to the given `Bank.Customers.User` `:email`,
  informing the withdrawal `amount`.
  """
  @spec send_user_account_withdraw_email(Bank.Customers.User.t(), Money.t()) :: Bamboo.Email.t()
  def send_user_account_withdraw_email(%User{} = user, %Money{} = money) do
    user
    |> UserAccountWithdrawEmail.build(money)
    |> Mailer.deliver_later()
  end
end
