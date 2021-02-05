defmodule Bank.Customers.Account do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Money.Sigils

  alias Bank.Customers.User
  alias Bank.Financial.Transaction

  @required_fields [:number, :balance, :user_id]
  @default_balance_value ~M[100_000]

  @type t :: %__MODULE__{
          id: integer(),
          user: User.t() | %Ecto.Association.NotLoaded{},
          balance: Money.Ecto.Amount.Type.type(),
          number: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "accounts" do
    field :balance, Money.Ecto.Amount.Type, default: @default_balance_value
    field :number, :string, null: false

    belongs_to :user, User
    has_many :transactions, Transaction

    timestamps()
  end

  @spec changeset(Bank.Customers.Account.t(), map()) :: Ecto.Changeset.t()
  @doc false
  def changeset(%__MODULE__{} = account, attrs) do
    account
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:number, is: 6)
    |> validate_balance()
    |> unique_constraint(:number)
    |> assoc_constraint(:user)
  end

  def withdraw_changeset(%__MODULE__{} = account, %Money{} = money) do
    changeset = change(account, balance: money)

    cond do
      Money.zero?(money) or Money.negative?(money) ->
        add_error(changeset, :balance, "withdrawal must be greater than #{~M[0]}")

      Money.compare(account.balance, money) == -1 ->
        message = "insufficient balance to withdraw #{Money.to_string(money)}"
        add_error(changeset, :balance, message)

      Money.compare(account.balance, money) == 0 ->
        put_change(changeset, :balance, ~M[0])

      true ->
        withdrawal_amount = get_change(changeset, :balance)
        put_change(changeset, :balance, Money.subtract(account.balance, withdrawal_amount))
    end
  end

  defp validate_balance(changeset) do
    validate_change(changeset, :balance, fn _, money ->
      if Money.compare(money, ~M[0]) == -1 do
        [balance: "must be greater than or equal to #{Money.to_string(~M[0])}"]
      else
        []
      end
    end)
  end
end
