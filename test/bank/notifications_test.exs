defmodule Bank.NotificationsTest do
  use Bank.DataCase, async: true
  use Bamboo.Test

  alias Bamboo.Email
  alias Bank.Customers.User
  alias Bank.Notifications
  alias Bank.Notifications.{UserAccountWithdrawEmail, Mailer}

  import Bank.Factory
  import Mock

  setup [:create_user, :create_account]

  describe "send_user_account_withdraw_email/2" do
    test "Sends a user account withdraw email to received user email", %{user: user} do
      build_mock = fn %User{}, %Money{} -> %Email{} end
      deliver_later_mock = fn %Email{} -> :ok end

      mocks = [
        {UserAccountWithdrawEmail, [], build: build_mock},
        {Mailer, [], deliver_later: deliver_later_mock}
      ]

      with_mocks mocks do
        money = Money.new(1_000)
        email = UserAccountWithdrawEmail.build(user, money)

        Notifications.send_user_account_withdraw_email(user, money)

        assert_called(UserAccountWithdrawEmail.build(user, money))
        assert_called(Mailer.deliver_later(email))
      end
    end
  end

  defp create_user(_context), do: {:ok, user: build(:user)}

  defp create_account(%{user: user}), do: {:ok, account: build(:account, user: user)}
end
