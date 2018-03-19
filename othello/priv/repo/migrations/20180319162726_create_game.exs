defmodule Othello.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:game) do
      add :is_over, :boolean, default: false, null: false
      add :player1_id, references(:users, on_delete: :delete_all), null: false
      add :player2_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:game, [:player1_id])
    create index(:game, [:player2_id])
  end
end
