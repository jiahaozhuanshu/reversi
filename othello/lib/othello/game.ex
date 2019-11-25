defmodule Othello.Game do
  def new do
    %{
      # creating a board as that similar to reversi
      game_board: reversi(),
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

    chess_color = 
    cond do
    game.black_player == game.player ->
      1
    game.white_player == game.player ->
      2
    Enum.member?(game.observers, game.player) ->
      0
    true ->
      -1
  end
      
    legal_moves = legal_moves_options(client_view.game_board, chess_color)
    Map.put(client_view, :legal_moves, legal_moves)
  end



 # first user will be added as white player
 # second user will be added as black player
 # the following players will be added as observers

  def add_new_player(game, user_name) do
      chats = game.chats

    cond do
      game.black_player == user_name or game.white_player == user_name or
          Enum.member?(game.observers, user_name) ->
        game

        # String.length(user_name) == 0 ->
        #        game
        #        |> Map.put(
        #          :chats,
        #          List.insert_at(chats, -1, [
        #            "system",
        #            "" <>
        #              user_name <> " joined the game as an observer and can only see the game in play."
        #          ])
        #        )
        #        |> Map.put(:observers, List.insert_at(game.observers, -1, user_name))


      # game.black_player == nil or game.white_player == nil ->
        game.white_player == nil ->
          game
          |> Map.put(:white_player, user_name)

          |> Map.put(
            :chats,
            List.insert_at(chats, -1, ["system","" <> user_name <> " joined as the white player."])
          )
        
        
        game.black_player == nil ->
          game
          |> Map.put(:black_player, user_name)
          |> Map.put(:player, user_name)
          |> Map.put(:status, "Playing")
          |> Map.put(
            :chats,
            List.insert_at(chats, -1, ["system","" <> user_name <> " joined as the black player."
            ])
          )
        

      true ->
        game
        |> Map.put(:observers, List.insert_at(game.observers, -1, user_name))
        |> Map.put(
          :chats,
          List.insert_at(chats, -1, ["system","" <>user_name <> " joined as an observer."])
        )
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
def legal_moves_options(game_board, chess_color) do

  Enum.reduce(Enum.to_list(0..63), [], fn (i, legal_moves) ->
    if legal_move(game_board, i, chess_color) do
      List.insert_at(legal_moves, -1, i)
    else
      legal_moves
    end
  end)
end

# Determining whether the move is legal or not that is when trying to click at
# the cell where a move cannot be made

defp legal_move(game_board, i, chess_color) do
  row = div(i, 8)
  column = rem(i, 8)

  if game_board
     |> Enum.at(row)
     |> Enum.at(column) != 0 do
    false
  else
    potential_directions = [[0, 1], [1, 0], [-1, 0], [0, -1], [1, -1], [-1, 1], [1, 1], [-1, -1]]

    Enum.any?(potential_directions, fn (possible_move) ->
      is_direction_legal(game_board, 8, row, column, possible_move, chess_color)
    end)
  end
end

# Determining whether the move is legal or not that is when trying to click at
# the cell where a move cannot be made

defp is_direction_legal(game_board, size, row, column, possible_move, chess_color) do
  # cur_row = row + List.first(possible_move)
  cur_row = row + Enum.at(possible_move, 0)
  cur_col = column + Enum.at(possible_move, 1)

  cond do
    # if the current move is out of the board
    cur_row < 0 or cur_row >= size or cur_col < 0 or cur_col >= size ->
    false

    #if there is no chess pieces around the the clicked point
    game_board |> Enum.at(cur_row) |> Enum.at(cur_col) == 0 ->
    false

    #if 
    game_board |> Enum.at(cur_row) |> Enum.at(cur_col) == chess_color ->
    false

    true ->
      next_row = cur_row + List.first(possible_move)
      next_col = cur_col + List.last(possible_move)
      is_same_color(game_board, size, next_row, next_col, possible_move, chess_color)
  end
end

# To determine whether the color for the disc is same or not depending upon the
#  possible moves.
defp is_same_color(game_board, size, row, column, possible_move, chess_color) do
  cond do
    row < 0 or row >= size or column < 0 or column >= size ->
      false

    game_board |> Enum.at(row) |> Enum.at(column) == chess_color ->
      true

    game_board |> Enum.at(row) |> Enum.at(column) == 0 ->
      false

    true ->
      column_depth1 = column + List.last(possible_move)
      row_depth1 = row + List.first(possible_move)
      is_same_color(game_board, size, row_depth1, column_depth1, possible_move, chess_color)
  end
end

# update the number of chess pieces for  players
defp update_score(game, player_color) do
  game.game_board
  |> Enum.concat()
  |> Enum.reduce(0, fn x, acc ->
    if x == player_color, do: acc + 1, else: acc
  end)
end


# make a move and flip chess pieces if the move is legal
def move(game, chess_color, row, column) do
  potential_directions = [[0, 1], [1, 0], [-1, 0], [0, -1], [1, -1], [-1, 1], [1, 1], [-1, -1]]

  game =
    Enum.reduce(potential_directions, game, fn possible_move, game ->
      if is_direction_legal(game.game_board, 8, row, column, possible_move, chess_color) do
        user_name =
          if chess_color == 1 do
            game.black_player
          else
            game.white_player
          end

        next_row = row + Enum.at(possible_move, 0)
        next_col = column + Enum.at(possible_move, 1)
        new_game_board = flip_tiles(game.game_board, next_row, next_col, possible_move, chess_color)

        game
        |> Map.put(:game_board, new_game_board)
      else
        game
      end
    end)

  # change the clicked tile to the color of the current user
  new_game_board = List.replace_at(game.game_board, row,List.replace_at(Enum.at(game.game_board, row), column, chess_color))
  game = Map.put(game, :game_board, new_game_board)
  game = change_player(game)

  game
  |> Map.put(:white_disc, update_score(game, 2))
  |> Map.put(:black_disc, update_score(game, 1))
end

# flip chess pieces after every move
defp flip_tiles(game_board, row, column, possible_move, chess_color) do
  cond do
    # if the color of current pieces is  the same as current user, then return 
    game_board |> Enum.at(row) |> Enum.at(column) == chess_color ->
      game_board

    # if the color of the current pieces is the opposite one, then flip the chess pieces
    # and continue toward the original direction
    true ->
      new_game_board =List.replace_at(game_board, row,List.replace_at(Enum.at(game_board, row), column, chess_color))
      next_row = row + Enum.at(possible_move, 0)
      next_col = column + Enum.at(possible_move, 1)
      flip_tiles(new_game_board, next_row, next_col, possible_move, chess_color)
  end
end

  # Creating the reversi board for use
  # 2: white color
  # 1: black color
  # 0: empty

  defp reversi() do
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
end
