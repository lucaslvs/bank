defmodule Bank.Financial.Transaction do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Bank.Customers.Account

  @required_fields [:amount, :account_id]

  @type t() :: %__MODULE__{
          id: integer(),
          account: Account.t() | %Ecto.Association.NotLoaded{},
          account_id: integer(),
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
    |> assoc_constraint(:account)
  end
end
