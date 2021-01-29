defmodule Bank.Communications.Mail do
  @moduledoc """
  A module that map definitions used by each email adapter.

  This can be used in your application as:

      use Bank.Communications.Mail, :sendgrid
      use Bank.Communications.Mail, :another_email_adapter
  """

  @callback build(Bank.Customers.User.t(), any()) :: Bamboo.Email.t()

  def sendgrid do
    quote do
      @behaviour Bank.Communications.Mail

      import Bamboo.Email
      import Bamboo.SendGridAdapter
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
