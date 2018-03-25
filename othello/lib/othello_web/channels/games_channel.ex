defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Othello.GameBackUp

  def join("games:" <> game_name, params, socket) do
    user_name = params["user_name"]
    game = GameBackUp.load(game_name) || Game.new()
    game = Game.add_new_player(game, user_name)
    GameBackUp.save(game_name, game)

    socket =
      socket
      |> assign(:name, game_name)

    send(self(), :after_join)
    {:ok, %{"join" => game_name, "game" => Game.client_view(game)}, socket}
  end

  def handle_info(:after_join, socket) do
    game = GameBackUp.load(socket.assigns[:name])
    broadcast!(socket, "join", %{"game_state" => Game.client_view(game)})
    {:noreply, socket}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("move", %{"row" => row, "column" => col, "player_name" => disc_color}, socket) do
    game = GameBackUp.load(socket.assigns[:name])
    game = Game.move(game, disc_color, row, col)
    GameBackUp.save(socket.assigns[:name], game)
    broadcast!(socket, "move", %{"game_state" => Game.client_view(game)})
    {:noreply, socket}
  end

  def handle_in("change_player", _payload, socket) do
    game = GameBackUp.load(socket.assigns[:name])
    game = Game.change_player(game)
    GameBackUp.save(socket.assigns[:name], game)

    if game.status == "Completed" do
      broadcast!(socket, "finish", %{"game_state" => Game.client_view(game)})
      {:noreply, socket}
    else
      broadcast!(socket, "move", %{"game_state" => Game.client_view(game)})
      {:noreply, socket}
    end
  end

  def handle_in("start_chat", %{"user_name" => user_name, "msg" => msg}, socket) do
    game = GameBackUp.load(socket.assigns[:name])
    game = Game.start_chat(game, user_name, msg)
    GameBackUp.save(socket.assigns[:name], game)
    broadcast!(socket, "player_msg", %{"game_state" => Game.client_view(game)})
    {:noreply, socket}
  end
end

# Attribution: https://hexdocs.pm/phoenix/presence.html#content
# Attribution: https://github.com/NatTuck/hangman2
