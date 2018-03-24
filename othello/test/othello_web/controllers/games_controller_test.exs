defmodule OthelloWeb.GamesControllerTest do
  use OthelloWeb.ConnCase

  alias Othello.Play

  @create_attrs %{is_over: true}
  @update_attrs %{is_over: false}
  @invalid_attrs %{is_over: nil}

  def fixture(:games) do
    {:ok, games} = Play.create_games(@create_attrs)
    games
  end

  describe "index" do
    test "lists all game", %{conn: conn} do
      conn = get conn, games_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Game"
    end
  end

  describe "new games" do
    test "renders form", %{conn: conn} do
      conn = get conn, games_path(conn, :new)
      assert html_response(conn, 200) =~ "New Games"
    end
  end

  describe "create games" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, games_path(conn, :create), games: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == games_path(conn, :show, id)

      conn = get conn, games_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Games"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, games_path(conn, :create), games: @invalid_attrs
      assert html_response(conn, 200) =~ "New Games"
    end
  end

  describe "edit games" do
    setup [:create_games]

    test "renders form for editing chosen games", %{conn: conn, games: games} do
      conn = get conn, games_path(conn, :edit, games)
      assert html_response(conn, 200) =~ "Edit Games"
    end
  end

  describe "update games" do
    setup [:create_games]

    test "redirects when data is valid", %{conn: conn, games: games} do
      conn = put conn, games_path(conn, :update, games), games: @update_attrs
      assert redirected_to(conn) == games_path(conn, :show, games)

      conn = get conn, games_path(conn, :show, games)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, games: games} do
      conn = put conn, games_path(conn, :update, games), games: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Games"
    end
  end

  describe "delete games" do
    setup [:create_games]

    test "deletes chosen games", %{conn: conn, games: games} do
      conn = delete conn, games_path(conn, :delete, games)
      assert redirected_to(conn) == games_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, games_path(conn, :show, games)
      end
    end
  end

  defp create_games(_) do
    games = fixture(:games)
    {:ok, games: games}
  end
end
