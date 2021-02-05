defmodule Bank.Customers.Account do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Money.Sigils

  alias Bank.Customers.User
  alias Bank.Financial.Transaction

  @required_fields [:number, :balance, :user_id]
  @default_balance_value ~M[100_000]
  @minimum_balance ~M[0]

  @type t :: %__MODULE__{
          id: integer(),
          user: User.t() | %Ecto.Association.NotLoaded{},
          user_id: integer(),
          balance: Money.Ecto.Amount.Type.type(),
          number: String.t(),
          transactions: list(Transaction.t()) | %Ecto.Association.NotLoaded{},
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

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = account, attrs) do
    account
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:number, is: 6)
    |> validate_balance()
    |> unique_constraint(:number)
    |> assoc_constraint(:user)
  end

  defp validate_balance(changeset) do
    validate_change(changeset, :balance, fn _, balance ->
      if Money.negative?(balance) do
        [balance: "must be greater than or equal to #{Money.to_string(@minimum_balance)}"]
      else
        []
      end
    end)
  end

  @doc false
  @spec deposit_changeset(t(), Money.t()) :: Ecto.Changeset.t()
  def deposit_changeset(%__MODULE__{balance: account_balance} = account, %Money{} = balance) do
    changeset = change(account, balance: balance)

    if is_invalid_balance?(balance) do
      add_error(changeset, :balance, "deposit must be greater than #{@minimum_balance}")
    else
      deposit_amount = get_field(changeset, :balance, @minimum_balance)
      put_change(changeset, :balance, Money.add(account_balance, deposit_amount))
    end
  end

  @doc false
  @spec withdraw_changeset(t(), Money.t()) :: Ecto.Changeset.t()
  def withdraw_changeset(%__MODULE__{balance: account_balance} = account, %Money{} = balance) do
    changeset = change(account, balance: balance)

    cond do
      is_invalid_balance?(balance) ->
        add_error(changeset, :balance, "withdrawal must be greater than #{@minimum_balance}")

      is_insufficient_balance_to_withdraw?(account_balance, balance) ->
        message = "insufficient balance to withdraw #{Money.to_string(balance)}"
        add_error(changeset, :balance, message)

      true ->
        withdrawal_amount = get_field(changeset, :balance, @minimum_balance)
        put_change(changeset, :balance, Money.subtract(account_balance, withdrawal_amount))
    end
  end

  defp is_insufficient_balance_to_withdraw?(account_balance, balance) do
    Money.compare(account_balance, balance) == -1
  end

  defp is_invalid_balance?(%Money{} = balance) do
    Money.zero?(balance) or Money.negative?(balance)
  end
end
