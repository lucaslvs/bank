defmodule Bank.Financial.Transaction.QueryBuilder do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Bank.Financial.Transaction

  @spec filter(map()) :: Ecto.Query.t()
  def filter(params) when is_map(params) do
    Transaction
    |> order_by(^filter_order_by(params["order_by"]))
    |> where(^filter_where(params))
  end

  defp filter_order_by("inserted_at"), do: dynamic([t], t.inserted_at)

  defp filter_order_by("inserted_at_desc"), do: [desc: dynamic([t], t.inserted_at)]

  defp filter_order_by(_), do: []

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"inserted_at", inserted_at}, dynamic ->
        dynamic([t], ^dynamic and fragment("?::date", t.inserted_at) <= ^inserted_at)

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
