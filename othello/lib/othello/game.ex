defmodule Othello.Game do
  def new do
    %{
      # creating a board as that similar to othello
      game_board: othello(),
      # The player with the black disc
      black_player: nil,
      # The player with the black disc
      white_player: nil,
      # The player whose turn is to make a move
      player: nil,
      # List of all the available observers for the game
      observers: [],
      # List of chats thta have been generated
      chats: [],
      # status of the game such as waiting, finish and playing
      status: "Waiting"
    }
  end

  # Initializing the game_board fo the client view
  def client_view(game) do
    client_view = %{
      game_board: game.game_board,
      black_player: game.black_player,
      white_player: game.white_player,
      observers: game.observers,
      chats: game.chats,
      player: game.player,
      # the number of black discs in play
      black_disc: update_score(game, 1),
      # the number of white discs in play
      white_disc: update_score(game, 2),
      status: game.status
    }

    disc_color = who_am_I?(game, game.player)
    legal_moves = legal_moves_options(client_view.game_board, disc_color)
    Map.put(client_view, :legal_moves, legal_moves)
  end

  # Attribution: https://boardgames.stackexchange.com/questions/20572/how-to-approach-a-game-of-othello-reversi-game
  # Creating the othello board for use
  # 2 when the disc is of white color
  # 1 when the disc is of black color
  # 0 when there are no disc in the board

  defp othello() do
    [
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 2, 0, 0, 0],
      [0, 0, 0, 2, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0]
    ]
  end

  # Add a new player as black_player and white_player, once both the users are
  # added all other users will be added as observers.

  def add_new_player(game, user_name) do
    chats = game.chats

    cond do
      game.black_player == user_name or game.white_player == user_name or
          Enum.member?(game.observers, user_name) ->
        game

      game.black_player == nil or game.white_player == nil ->
        if game.white_player == nil  do
          game
          |> Map.put(
            :chats,
            List.insert_at(chats, -1, [
              "system",
              "" <> user_name <> " joined the game and will be playing with the white discs."
            ])
          )
          |> Map.put(:white_player, user_name)
        else
          if String.length(user_name) == 0 do
            game
            |> Map.put(
              :chats,
              List.insert_at(chats, -1, [
                "system",
                "" <>
                  user_name <> " joined the game as an observer and can only see the game in play."
              ])
            )
            |> Map.put(:observers, List.insert_at(game.observers, -1, user_name))

          else
            user_name != nil
            game
            |> Map.put(
              :chats,
              List.insert_at(chats, -1, [
                "system",
                "" <> user_name <> " joined the game and will be playing with the black discs."
              ])
            )
            |> Map.put(:black_player, user_name)
            |> Map.put(:player, user_name)
            |> Map.put(:status, "Playing")
          end          
        end
    end
  end

  # Changing the player fatre every move and if there are no moves left then
  # updating the game status as finsihed.
  def change_player(game) do
    game =
      if game.player == game.white_player do
        Map.put(game, :player, game.black_player)
      else
        Map.put(game, :player, game.white_player)
      end

    game =
      if Enum.count(client_view(game).legal_moves) == 0 do
        Map.put(game, :status, "Completed")
      else
        game
      end

    game
  end

  # starting a chat by sending a message to the chat window
  def start_chat(game, user_name, msg) do
    if user_name == game.white_player or user_name == game.black_player do
      Map.put(
        game,
        :chats,
        List.insert_at(game.chats, -1, ["player", "[" <> user_name <> "]: " <> msg])
      )
    else
      Map.put(
        game,
        :chats,
        List.insert_at(game.chats, -1, ["observer", "[" <> user_name <> "]: " <> msg])
      )
    end
  end

# Determining all the legal moves that are available for the given player
def legal_moves_options(game_board, disc_color) do
  size = Enum.count(game_board)

  Enum.reduce(Enum.to_list(0..(size * size - 1)), [], fn i, legal_moves ->
    if is_legal_move?(game_board, i, disc_color) do
      List.insert_at(legal_moves, -1, i)
    else
      legal_moves
    end
  end)
end

# Determining whether the move is legal or not that is when trying to click at
# the cell where a move cannot be made

defp is_legal_move?(game_board, i, disc_color) do
  size = Enum.count(game_board)
  row = div(i, size)
  column = rem(i, size)

  if game_board
     |> Enum.at(row)
     |> Enum.at(column) != 0 do
    false
  else
    possible_moves = [[0, 1], [1, 0], [-1, 0], [0, -1], [1, -1], [-1, 1], [1, 1], [-1, -1]]

    Enum.any?(possible_moves, fn possible_move ->
      is_legal_move?(game_board, size, row, column, possible_move, disc_color)
    end)
  end
end

# Determining whether the move is legal or not that is when trying to click at
# the cell where a move cannot be made

defp is_legal_move?(game_board, size, row, column, possible_move, disc_color) do
  row_depth1 = row + List.first(possible_move)
  column_depth1 = column + List.last(possible_move)

  cond do
    row_depth1 < 0 or row_depth1 >= size or column_depth1 < 0 or column_depth1 >= size ->
      false

    game_board |> Enum.at(row_depth1) |> Enum.at(column_depth1) == 0 or
        game_board |> Enum.at(row_depth1) |> Enum.at(column_depth1) == disc_color ->
      false

    true ->
      row_depth2 = row_depth1 + List.first(possible_move)
      column_depth2 = column_depth1 + List.last(possible_move)
      same_disc?(game_board, size, row_depth2, column_depth2, possible_move, disc_color)
  end
end

# To determine whether the color for the disc is same or not depending upon the
#  possible moves.
defp same_disc?(game_board, size, row, column, possible_move, disc_color) do
  cond do
    row < 0 or row >= size or column < 0 or column >= size ->
      false

    game_board |> Enum.at(row) |> Enum.at(column) == disc_color ->
      true

    game_board |> Enum.at(row) |> Enum.at(column) == 0 ->
      false

    true ->
      column_depth1 = column + List.last(possible_move)
      row_depth1 = row + List.first(possible_move)
      same_disc?(game_board, size, row_depth1, column_depth1, possible_move, disc_color)
  end
end

# Counting the number of black and white discs, so as to update the score to
# decide the winner.
defp update_score(game, cell_num) do
  game.game_board
  |> Enum.concat()
  |> Enum.reduce(0, fn x, accumulator ->
    if x == cell_num, do: accumulator + 1, else: accumulator
  end)
end

# Determining the player assigned to the username based on the following values:
# 1 : is for the black_player
# 2 : is for the white_player
# -1 : is for others

defp who_am_I?(game, user_name) do
  cond do
    game.black_player == user_name ->
      1

    game.white_player == user_name ->
      2

    Enum.member?(game.observers, user_name) ->
      0

    true ->
      -1
  end
end

# Making a move that is when the user clicks on any empty space, he will be making
# a move so as to make all others in the line if a legal move.
def move(game, disc_color, row, column) do
  size = Enum.count(game.game_board)
  possible_moves = [[0, 1], [1, 0], [-1, 0], [0, -1], [1, -1], [-1, 1], [1, 1], [-1, -1]]

  game =
    Enum.reduce(possible_moves, game, fn possible_move, game ->
      if is_legal_move?(game.game_board, size, row, column, possible_move, disc_color) do
        user_name =
          if disc_color == 1 do
            game.black_player
          else
            game.white_player
          end

        row_depth1 = row + List.first(possible_move)
        column_depth1 = column + List.last(possible_move)

        new_game_board =
          change_disc_count(
            game.game_board,
            row_depth1,
            column_depth1,
            possible_move,
            disc_color
          )

        game
        |> Map.put(
          :chats,
          List.insert_at(game.chats, -1, [
            "system",
            "" <> user_name <> " has moved a disc."
          ])
        )
        |> Map.put(:game_board, new_game_board)
      else
        game
      end
    end)

  new_game_board =
    List.replace_at(
      game.game_board,
      row,
      List.replace_at(Enum.at(game.game_board, row), column, disc_color)
    )

  game = Map.put(game, :game_board, new_game_board)
  game = change_player(game)

  game
  |> Map.put(:white_disc, update_score(game, 2))
  |> Map.put(:black_disc, update_score(game, 1))
end

# changing the count of the discs of both black and white after every move
defp change_disc_count(game_board, row, column, possible_move, disc_color) do
  cond do
    game_board |> Enum.at(row) |> Enum.at(column) == disc_color ->
      game_board

    true ->
      new_game_board =
        List.replace_at(
          game_board,
          row,
          List.replace_at(Enum.at(game_board, row), column, disc_color)
        )

      row_depth1 = row + List.first(possible_move)
      column_depth1 = column + List.last(possible_move)
      change_disc_count(new_game_board, row_depth1, column_depth1, possible_move, disc_color)
  end
end
end
