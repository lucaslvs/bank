defmodule Bank.Financial.Transaction do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Bank.Customers.Account

  @required_fields [:amount, :account_id]

  @type t() :: %__MODULE__{
    id: integer(),
    account: Account.t() | %Ecto.Association.NotLoaded{},
    amount: Money.Ecto.Amount.Type.type(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t()
  }

  schema "transactions" do
    field :amount, Money.Ecto.Amount.Type, null: false
    belongs_to :account, Account

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = transaction, attrs) do
    transaction
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_amount()
    |> assoc_constraint(:account)
  end

  defp validate_amount(changeset) do
    validate_change(changeset, :amount, fn
      _, %Money{amount: amount} when amount > 0 -> []
      _, _ -> [amount: "must be greater than 0"]
    end)
  end
end
