defmodule TZ48.Game do
  @moduledoc """
  The 2048 Gameboard.

  This module provides the 2048 game board and provides functions
  for starting the game, processing each moves and finding out the
  game state at the end of each move.
  """

  alias TZ48.Util

  defstruct id: nil,
            board: [],
            players: [],
            state: :continue,
            last_move: nil,
            new_coords: nil,
            messages: []

  @doc """
  Start a new game.

  The game board is a nested rowsxcols list with each tile having the possibility to store one of the following values:
  2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2 or `:empty`. When initialized, all values are :empty.
  """
  def new(opts) do
    %__MODULE__{id: opts[:id], board: get_board()}
  end

  @rows 6
  @cols 6
  defp get_board() do
    List.duplicate(:empty, @cols)
    |> List.duplicate(@rows)
  end

  @doc """
  Places the `@initial_tile` at a random `:empty` tile
  """
  @initial_tile 2
  def start_game(game) do
    place_random_tile(game, @initial_tile)
  end

  @doc """
  Adds a player pid to the current player list.
  """
  def join(game, pid) do
    players = [pid] ++ game.players
    %{game | players: players}
  end

  @doc """
  Adds a player pid to the current player list.
  """
  def exit(game, pid) do
    players = List.delete(game.players, pid)
    %{game | players: players}
  end

  @doc """
  Places a random tile from `@tile_options` at a random `:empty` tile.
  """
  @tile_options [2, 4]
  def place_random_tile(game, tile \\ nil) do
    tile = tile || Enum.random(@tile_options)
    empty_spots = find_empty_spots(game.board)
    random_spot = Enum.random(empty_spots)
    %{game | board: do_place_tile(game.board, random_spot, tile), new_coords: random_spot}
    # {do_place_tile(board, random_spot, tile), random_spot}
  end

  @doc """
  Add a chat message to the message list.
  """
  def add_message(game, message) do
    messages = game.messages

    %{game | messages: [message | messages]}
  end

  defp do_place_tile(board, {x, y} = _spot, tile) do
    row = Enum.at(board, x)
    updated_row = List.update_at(row, y, fn _ -> tile end)
    List.update_at(board, x, fn _ -> updated_row end)
  end

  defp find_empty_spots(board) do
    board
    |> Enum.with_index()
    |> Enum.map(fn {row, rindex} ->
      row
      |> Enum.with_index()
      |> Enum.reduce([], fn {tile, cindex}, acc ->
        if(tile == :empty) do
          acc ++ [cindex]
        else
          acc
        end
      end)
      |> Enum.map(fn cindex -> {rindex, cindex} end)
    end)
    |> List.flatten()
  end

  @doc """
  Checks the state of the gameboard.

  Game state is one of the following values: won, lost, continue.
  Though theoritically a tile's value can be higher than 2048, we declare the game as won as soon
  one of the tiles reaches the value 2048 and we stop any further movements in the game.

  If any of the tile has the value 2048, then return `:won`
  or if the number of tiles that have :empty values is exactly one, then return `:lost`
  or else return `:continue`
  """
  def process_state(board) do
    cond do
      has_won?(board) -> :won
      count_empty_tiles(board) == 0 -> :lost
      true -> :continue
    end
  end

  @doc """
  Process command to move tiles to the given direction.

  Direction can be either :right, :left, :up, :down.

  Because we are using Enum maps for processing the tiles after movement,
  we cannot process the upward and downward movement directly.

  We do this by tranposing the rows as columns then do :left movement for :up and :right movement
  for :down and then transpose again.
  """
  def process_move(game, direction) do
    board = game.board
    updated_board = do_process_move(board, direction)
    state = process_state(updated_board)

    %{game | state: state, board: updated_board, last_move: direction}
  end

  defp do_process_move(board, :right) do
    Enum.map(board, fn row ->
      row
      |> Enum.reverse()
      |> process_row
      |> Enum.reverse()
    end)
  end

  defp do_process_move(board, :left) do
    Enum.map(board, fn row ->
      process_row(row)
    end)
  end

  defp do_process_move(board, :up) do
    board
    |> Util.transpose()
    |> do_process_move(:left)
    |> Util.transpose()
  end

  defp do_process_move(board, :down) do
    board
    |> Util.transpose()
    |> do_process_move(:right)
    |> Util.transpose()
  end


  defp process_row(row) do
    length = Enum.count(row)

    row =
      Enum.reduce(row, [], fn tile, acc ->
        cond do
          is_empty_tile?(tile) ->
            acc

          acc == [] ->
            [tile]

          is_mergable_tile?(tile, acc) ->
            [h | t] = acc
            [h + tile] ++ t

          true ->
            [tile] ++ acc
        end
      end)
      |> Enum.reverse() # Since we are prepending each element to the list, we need to reverse to the order correct.

    # Since we remove empty items, we need to ensure the new row is still having same number of items.
    # We pad with :empty tile for the difference.
    padding = Stream.cycle([:empty]) |> Enum.take(length - Enum.count(row))

    row ++ padding
  end

  defp is_empty_tile?(tile), do: tile == :empty

  defp is_mergable_tile?(tile, [h | _]) do
    h == tile
  end

  defp is_mergable_tile?(_, []), do: false

  defp has_won?(board) do
    List.flatten(board)
    |> Enum.member?(2048)
  end

  defp count_empty_tiles(board) do
    find_empty_spots(board)
    |> Enum.count()
  end
end
