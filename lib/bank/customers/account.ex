defmodule Bank.Customers.Account do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Bank.Customers.User

  @required_fields [:number, :user_id]
  @optional_fields [:balance]

  @type t :: %__MODULE__{
          id: integer(),
          user: User.t() | %Ecto.Association.NotLoaded{},
          balance: Money.Ecto.Amount.Type.type(),
          number: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "accounts" do
    field :balance, Money.Ecto.Amount.Type, default: Money.new(0)
    field :number, :string, null: false

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = account, attrs) do
    account
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:number, is: 6)
    |> validate_money(:balance)
    |> unique_constraint(:number)
    |> assoc_constraint(:user)
    |> foreign_key_constraint(:user_id)
  end

  defp validate_money(changeset, field) do
    validate_change(changeset, field, fn
      _, %Money{amount: amount} when amount >= 0 -> []
      _, _ -> [amount: "must be greater than or equal to 0"]
    end)
  end
end
