defmodule Othello.Play.Games do
  use Ecto.Schema
  import Ecto.Changeset


  schema "game" do
    field :is_over, :boolean, default: false
    field :player1_id, User
    field :player2_id, User

    timestamps()
  end

  @doc false
  def changeset(games, attrs) do
    games
    |> cast(attrs, [:is_over, :player_one_d, :player_two_id])
    |> validate_required([:is_over, :player_one_id])          #Only 1 player is required to start a game
  end
end
