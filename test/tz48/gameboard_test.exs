defmodule TZ48.GameboardTest do
  use ExUnit.Case

  alias TZ48.Gameboard

  test "game board dimension to be 6x6 list" do
    board = Gameboard.get_board()
    assert Enum.count(board) == 6
    Enum.each(board, fn(row) ->
      assert Enum.count(row) == 6
    end)
  end

  test "start game places 2 on a random location" do
    board = Gameboard.get_board()
    board = Gameboard.start_game(board)

    non_empty_tiles = get_non_empty_tiles(board)

    assert non_empty_tiles == [2]
  end

  describe "place_random_tile/2" do
    test "places 2 or 4" do
      board = Gameboard.get_board()
      board = Gameboard.place_random_tile(board)

      non_empty_tiles = get_non_empty_tiles(board)

      assert Enum.member?([[2], [4]], non_empty_tiles)
    end

    @total_tiles 36
    test "doesn't overwrite existing tile" do
      board = get_board_with_only_one_empty_tile()

      board = Gameboard.place_random_tile(board)
      non_empty_tiles = get_non_empty_tiles(board)

      assert Enum.count(non_empty_tiles) == @total_tiles
    end

  end

  describe "process_move/2" do
    test "move right" do

    end

    test "move left" do

    end

    test "move up" do

    end

    test "move down" do

    end
  end

  describe "process_state/1" do
    test "check if game is won" do
      board = [
        [2, 2, 2, 2, 2, 2],
        [2, 2, 2, 2, 2, 2],
        [2, 2, 2048, 2, 2, 2],
        [2, 2, 2, :empty, 2, 2],
        [2, 2, 2, 2, 2, 2],
        [2, 2, 2, 2, 2, 2]
      ]

      assert Gameboard.process_state(board) == :won
    end

    test "check if game is lost" do
      board = get_board_with_only_one_empty_tile()

      assert Gameboard.process_state(board) == :lost
    end

    test "check if game can continue" do
      board = [
        [2, 2, 2, 2, 2, 2],
        [2, :empty, 2, 2, 2, 2],
        [2, 2, :empty, 2, 2, 2],
        [2, 2, 2, :empty, 2, 2],
        [2, 2, 2, 2, 2, 2],
        [2, 2, 2, 2, 2, 2]
      ]

      assert Gameboard.process_state(board) == :continue
    end
  end


  defp get_board_with_only_one_empty_tile() do
    [
      [2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2],
      [2, 2, :empty, 2, 2, 2],
      [2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2]
    ]
  end


  defp get_non_empty_tiles(board) do
    Enum.reduce(board, [], fn(row, acc) ->
      acc ++ Enum.reject(row, fn(tile) -> tile == :empty end)
    end)
    |> List.flatten()
  end
end
