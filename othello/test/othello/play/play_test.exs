defmodule Othello.PlayTest do
  use Othello.DataCase

  alias Othello.Play

  describe "game" do
    alias Othello.Play.Games

    @valid_attrs %{is_over: true}
    @update_attrs %{is_over: false}
    @invalid_attrs %{is_over: nil}

    def games_fixture(attrs \\ %{}) do
      {:ok, games} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Play.create_games()

      games
    end

    test "list_game/0 returns all game" do
      games = games_fixture()
      assert Play.list_game() == [games]
    end

    test "get_games!/1 returns the games with given id" do
      games = games_fixture()
      assert Play.get_games!(games.id) == games
    end

    test "create_games/1 with valid data creates a games" do
      assert {:ok, %Games{} = games} = Play.create_games(@valid_attrs)
      assert games.is_over == true
    end

    test "create_games/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Play.create_games(@invalid_attrs)
    end

    test "update_games/2 with valid data updates the games" do
      games = games_fixture()
      assert {:ok, games} = Play.update_games(games, @update_attrs)
      assert %Games{} = games
      assert games.is_over == false
    end

    test "update_games/2 with invalid data returns error changeset" do
      games = games_fixture()
      assert {:error, %Ecto.Changeset{}} = Play.update_games(games, @invalid_attrs)
      assert games == Play.get_games!(games.id)
    end

    test "delete_games/1 deletes the games" do
      games = games_fixture()
      assert {:ok, %Games{}} = Play.delete_games(games)
      assert_raise Ecto.NoResultsError, fn -> Play.get_games!(games.id) end
    end

    test "change_games/1 returns a games changeset" do
      games = games_fixture()
      assert %Ecto.Changeset{} = Play.change_games(games)
    end
  end
end
