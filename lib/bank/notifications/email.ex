defmodule Bank.Notifications.Email do
  @moduledoc """
  A module that map definitions used by each email adapter.

  This can be used in your application as:

      use Bank.Notifications.Email, :sendgrid
      use Bank.Notifications.Email, :another_email_adapter
  """

  @callback build(Bank.Customers.User.t(), any()) :: Bamboo.Email.t()

  def sendgrid do
    quote do
      @behaviour Bank.Notifications.Email

      import Bamboo.Email
      import Bamboo.SendGridAdapter
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
