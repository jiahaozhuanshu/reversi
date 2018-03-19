defmodule Othello.Play.Games do
  use Ecto.Schema
  import Ecto.Changeset


  schema "game" do
    field :is_over, :boolean, default: false
    field :player1_id, :id
    field :player2_id, :id

    timestamps()
  end

  @doc false
  def changeset(games, attrs) do
    games
    |> cast(attrs, [:is_over])
    |> validate_required([:is_over])
  end
end
