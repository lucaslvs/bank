defmodule Bank.Financial.Operation.LockAccountByNumber do
  @moduledoc false

  use Bank.Financial.Operation

  alias Bank.Customers.Account

  @type lock_account_by_number_params() :: %{key: atom(), number: String.t()}

  @impl Bank.Financial.Operation
  @spec build(lock_account_by_number_params()) :: Ecto.Multi.t()
  def build(%{key: key, number: number}) when is_atom(key) and is_binary(number) do
    Multi.run(Multi.new(), key, fn _, _ ->
      Account
      |> where([a], a.number == ^number)
      |> lock([_], "FOR UPDATE")
      |> Repo.one()
      |> case do
        %Account{number: ^number} = account ->
          {:ok, account}

        _ ->
          {:error, :not_found}
      end
    end)
  end
end
