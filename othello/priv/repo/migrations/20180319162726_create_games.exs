defmodule Othello.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :is_over, :boolean, default: false, null: false
      add :player1_id, references(:users, on_delete: :delete_all), null: false
      add :player2_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:games, [:player1_id])
    create index(:games, [:player2_id])
  end
end
