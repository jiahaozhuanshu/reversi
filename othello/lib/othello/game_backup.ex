# The methods start_linl, save and load have been referred from Professor Nat Tuck's notes:
# http://www.ccs.neu.edu/home/ntuck/courses/2018/01/cs4550/notes/10-proc-state/game_backup.ex

defmodule Othello.GameBackUp do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(name, game) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, game)
    end
  end

  def load(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end

#creating the lobby for the games to display all the games
  def game_lobby do
    Agent.get __MODULE__, fn state ->
      Map.keys(state)
    end
  end

  # Map all the games to be returned to the callee
  def all_games do
    Agent.get __MODULE__, fn state ->
      state
    end
  end
end
