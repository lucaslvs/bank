defmodule Bank.Customers.User do
  @moduledoc """
  A scheme responsible for modeling the bank customer's personal and access data.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Bank.Customers.Account

  @required_fields [:name, :email, :password]
  @email_format ~r/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  @type t :: %__MODULE__{
          id: integer(),
          account: Account.t() | %Ecto.Association.NotLoaded{},
          email: String.t(),
          password_hash: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "users" do
    field :email, :string, null: false
    field :name, :string, null: false
    field :password_hash, :string, null: false

    field :email_confirmation, :string, virtual: true
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_one :account, Account

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, @email_format)
    |> validate_length(:name, min: 1)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
  end

  @doc false
  def create_changeset(attrs) do
    __MODULE__
    |> struct()
    |> changeset(attrs)
    |> validate_confirmation(:email, required: true)
    |> validate_confirmation(:password, required: true)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        change(changeset, Argon2.add_hash(password))

      changeset ->
        changeset
    end
  end
end
