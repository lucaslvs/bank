defmodule Bank.Financial.Transaction do
  @moduledoc """
  A `Ecto.Schema.t()` responsible for modeling all transactions in an `Bank.Customers.Account`.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Bank.Customers.Account

  @required_fields [:amount, :type, :account_id]
  @types [:withdraw, :deposit, :transfer_deposit, :transfer_withdrawal]

  @type t() :: %__MODULE__{
          id: integer(),
          account: Account.t() | %Ecto.Association.NotLoaded{},
          account_id: integer(),
          type: Ecto.Enum.type(),
          amount: Money.Ecto.Amount.Type.type(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "transactions" do
    field :amount, Money.Ecto.Amount.Type, null: false
    field :type, Ecto.Enum, values: @types, null: false
    belongs_to :account, Account

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = transaction, attrs) do
    transaction
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @types)
    |> assoc_constraint(:account)
  end
end
