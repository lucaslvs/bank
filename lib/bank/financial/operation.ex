defmodule Bank.Financial.Operation do
  @moduledoc """
  A module that map definitions used by `Bank.Financial` context.

  This can be used in your application as:

      use Bank.Financial.Operation
  """

  @callback build(map()) :: Ecto.Multi.t()

  def multi do
    quote do
      @behaviour Bank.Financial.Operation

      import Ecto.Query, warn: false

      alias Bank.Repo
      alias Ecto.Multi
    end
  end

  defmacro __using__(_) do
    apply(__MODULE__, :multi, [])
  end
end
