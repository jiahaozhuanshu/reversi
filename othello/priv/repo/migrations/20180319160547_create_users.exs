defmodule Othello.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string
      add :pwd_tries, :integer,  null: false, default: 0
      add :last_session, :utc_datetime

      timestamps()
    end

  end
end
