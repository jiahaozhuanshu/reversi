defmodule OthelloWeb.PageController do
  use OthelloWeb, :controller

  alias Othello.GameBackUp

  # lobby: a list of game instances' names, which is actually a list of keys in the state map
  # instances: the entire state map
  def index(conn, _params) do
    render conn, "index.html", lobby: GameBackUp.game_lobby, all_games: GameBackUp.all_games
  end

  def game(conn, params) do
    render conn, "game.html", game: params["game"], user_name: params["user_name"]
  end

  def game_list(conn, _params) do
    render conn, "game_list.html", lobby: GameBackUp.game_lobby, all_games: GameBackUp.all_games
  end
end
