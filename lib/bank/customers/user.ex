defmodule Bank.Customers.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :email, :string, null: false
    field :name, :string, null: false
    field :password_hash, :string, null: false

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password_hash])
    |> validate_required([:name, :email, :password_hash])
    |> unique_constraint(:email)
  end
end
