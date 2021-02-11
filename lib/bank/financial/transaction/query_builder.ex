defmodule Bank.Financial.Transaction.QueryBuilder do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Bank.Financial.Transaction

  @spec filter(map()) :: Ecto.Query.t()
  def filter(params) when is_map(params) do
    where(Transaction, ^filter_where(params))
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"inserted_from", inserted_at}, dynamic ->
        dynamic([t], ^dynamic and fragment("?::date", t.inserted_at) >= ^inserted_at)

      {:inserted_from, inserted_at}, dynamic ->
        dynamic([t], ^dynamic and fragment("?::date", t.inserted_at) >= ^inserted_at)

      {"inserted_until", inserted_at}, dynamic ->
        dynamic([t], ^dynamic and fragment("?::date", t.inserted_at) <= ^inserted_at)

      {:inserted_until, inserted_at}, dynamic ->
        dynamic([t], ^dynamic and fragment("?::date", t.inserted_at) <= ^inserted_at)

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
