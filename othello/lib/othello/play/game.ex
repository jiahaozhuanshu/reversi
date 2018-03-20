defmodule Othello.Play.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Othello.Accounts.User

  schema "games" do
    field :is_over, :boolean, default: false
    belongs_to :player1, User
    belongs_to :player2, User
    has_many :states, State, foreign_key: :game_id

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:is_over, :player1_id, :player2_id])
    |> validate_required([:is_over, :player1_id])
  end
end
