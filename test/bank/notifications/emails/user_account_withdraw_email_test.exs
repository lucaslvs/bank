
defmodule Bank.Notifications.UserAccountWithdrawEmailTest do
  use Bank.DataCase, async: true
  use Bamboo.Test

  alias Bamboo.Email
  alias Bank.Notifications.UserAccountWithdrawEmail

  import Bank.Factory

  setup [:create_user, :create_account]

  describe "build/2" do
    test "Returns a user account withdraw email", %{user: user} do
      money = Money.new(1_000)
      email = UserAccountWithdrawEmail.build(user, money)

      assert %Email{} = email
      assert email.to == user.email
      assert email.from == "contact@bank.com"
      assert email.subject == "Saque realizado"
      assert email.text_body == """
      Olá, #{user.name}!

      Seu saque foi realizado com sucesso no valor de #{Money.to_string(money)}.
      """
    end
  end

  defp create_user(_context), do: {:ok, user: build(:user)}

  defp create_account(%{user: user}), do: {:ok, account: build(:account, user: user)}
end
