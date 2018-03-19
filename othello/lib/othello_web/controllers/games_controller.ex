defmodule OthelloWeb.GamesController do
  use OthelloWeb, :controller

  alias Othello.Play
  alias Othello.Play.Games

  def index(conn, _params) do
    game = Play.list_game()
    render(conn, "index.html", game: game)
  end

  def new(conn, _params) do
    changeset = Play.change_games(%Games{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"games" => games_params}) do
    case Play.create_games(games_params) do
      {:ok, games} ->
        conn
        |> put_flash(:info, "Games created successfully.")
        |> redirect(to: games_path(conn, :show, games))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    games = Play.get_games!(id)
    render(conn, "show.html", games: games)
  end

  def edit(conn, %{"id" => id}) do
    games = Play.get_games!(id)
    changeset = Play.change_games(games)
    render(conn, "edit.html", games: games, changeset: changeset)
  end

  def update(conn, %{"id" => id, "games" => games_params}) do
    games = Play.get_games!(id)

    case Play.update_games(games, games_params) do
      {:ok, games} ->
        conn
        |> put_flash(:info, "Games updated successfully.")
        |> redirect(to: games_path(conn, :show, games))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", games: games, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    games = Play.get_games!(id)
    {:ok, _games} = Play.delete_games(games)

    conn
    |> put_flash(:info, "Games deleted successfully.")
    |> redirect(to: games_path(conn, :index))
  end
end
