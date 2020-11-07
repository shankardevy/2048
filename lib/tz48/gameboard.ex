defmodule TZ48.Gameboard do
  @moduledoc """
  The 2048 Gameboard.

  This module provides the 2048 game board and provides functions
  for starting the game, processing each moves and finding out the
  game state at the end of each move.
  """


  @doc """
  Provides the gameboard grid.

  The game board is a nested rowsxcols list with each tile having the possibility to store one of the following values:
  2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2 or `:empty`. When initialized, all values are :empty.

  [
    [:empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty]
  ]
  """
  @rows 6
  @cols 6
  def get_board() do
    List.duplicate(:empty, @cols)
    |> List.duplicate(@rows)
  end

  @doc """
  Places the `@initial_tile` at a random `:empty` tile
  """
  @initial_tile 2
  def start_game(board) do
    place_random_tile(board, @initial_tile)
  end

  @doc """
  Places a random tile from `@tile_options` at a random `:empty` tile.
  """
  @tile_options [2, 4]
  def place_random_tile(board, tile \\ nil) do
    tile = tile || Enum.random(@tile_options)
    empty_spots = find_empty_spots(board)
    random_spot = Enum.random(empty_spots)
    do_place_tile(board, random_spot, tile)
  end

  defp do_place_tile(board, {x, y} = _spot, tile) do
    row = Enum.at(board, x)
    updated_row = List.update_at(row, y, fn(_) -> tile end)
    List.update_at(board, x, fn(_) -> updated_row end)
  end

  defp find_empty_spots(board) do
    board
      |> Enum.with_index()
      |> Enum.map(fn({row, rindex}) ->
            row
            |> Enum.with_index()
            |> Enum.reduce([], fn({tile, cindex}, acc) ->
                  if(tile == :empty) do
                    acc ++ [cindex]
                  else
                    acc
                  end
                end)
            |> Enum.map(fn(cindex) -> {rindex, cindex} end)
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
      count_empty_tiles(board) == 1 -> :lost
      true -> :continue
    end
  end

  @doc """
  Process command to move tiles to the given direction.

  Direction can be either :right, :left, :top, :bottom
  """
  def process_move(board, :right) do
    Enum.map(board, fn(row) ->

    end)
  end

  def process_move(board, :left) do

  end

  def process_move(board, :top) do

  end

  def process_move(board, :bottom) do

  end

  defp has_won?(board) do
    List.flatten(board)
    |> Enum.member?(2048)
  end

  defp count_empty_tiles(board) do
    find_empty_spots(board)
    |> Enum.count
  end

end
