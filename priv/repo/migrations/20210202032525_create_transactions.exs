defmodule Bank.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :integer, null: false
      add :account_id, references(:accounts, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:transactions, [:account_id])
  end
end
