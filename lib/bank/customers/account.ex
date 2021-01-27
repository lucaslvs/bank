defmodule Bank.Customers.Account do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Bank.Customers.User

  schema "accounts" do
    field :balance, Money.Ecto.Amount.Type, default: Money.new(0)
    field :number, :string, null: false

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:number, :balance])
    |> validate_required([:number, :balance])
    |> unique_constraint(:number)
  end
end
