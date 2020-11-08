defmodule TZ48.GameTest do
  use ExUnit.Case

  alias TZ48.Game

  test "game board dimension to be 6x6 list" do
    game = Game.new([])
    assert Enum.count(game.board) == 6

    Enum.each(game.board, fn row ->
      assert Enum.count(row) == 6
    end)
  end

  test "start game places 2 on a random location" do
    game =
      Game.new([])
      |> Game.start_game()

    non_empty_tiles = get_non_empty_tiles(game.board)

    assert non_empty_tiles == [2]
  end

  describe "place_random_tile/2" do
    test "places 2 or 4" do
      game =
        Game.new([])
        |> Game.place_random_tile()

      non_empty_tiles = get_non_empty_tiles(game.board)

      assert Enum.member?([[2], [4]], non_empty_tiles)
    end

    @total_tiles 36
    # TODO: Fix this. This test is fragile. It can randomly fail if
    # the implementation randomly overwrites a tile.
    test "doesn't overwrite existing tile" do
      game =
        get_game_with_only_one_empty_tile()
        |> Game.place_random_tile()

      non_empty_tiles = get_non_empty_tiles(game.board)

      assert Enum.count(non_empty_tiles) == @total_tiles
    end
  end

  describe "process_move/2" do
    test "move right" do
      board = [[:empty, 2, 2, 4, 4, :empty]]
      game = start_game(board)

      game = Game.process_move(game, :right)

      assert game.board == [[:empty, :empty, :empty, :empty, 4, 8]]
    end

    test "move left" do
      board = [[:empty, 2, 2, 4, 4, :empty]]
      game = start_game(board)

      game = Game.process_move(game, :left)

      assert game.board == [[8, 4, :empty, :empty, :empty, :empty]]
    end

    test "move up" do
      board = [[:empty], [2], [2], [:empty], [:empty], [2]]
      game = start_game(board)

      game = Game.process_move(game, :up)

      assert game.board == [[4], [2], [:empty], [:empty], [:empty], [:empty]]
    end

    test "move down" do
      board = [[:empty], [2], [2], [:empty], [:empty], [2]]
      game = start_game(board)

      game = Game.process_move(game, :down)

      assert game.board == [[:empty], [:empty], [:empty], [:empty], [2], [4]]
    end

    test "check if game is won" do
      board = [
        [1024, 1024, :empty, 2, 2, 2]
      ]

      game = start_game(board) |> Game.process_move(:left)

      assert game.state == :won
    end

    test "check if game is lost" do
      board = [
        [1, 2, 3, 4, 5, 6]
      ]

      game = start_game(board) |> Game.process_move(:left)

      assert game.state == :lost
    end

    test "check if game can continue" do
      board = [
        [1, 2, 2, 4, 5, 6]
      ]

      game = start_game(board) |> Game.process_move(:left)

      assert game.state == :continue
    end
  end

  defp get_game_with_only_one_empty_tile() do
    game = Game.new([])

    board = [
      [2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2],
      [2, 2, :empty, 2, 2, 2],
      [2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2]
    ]

    %{game | board: board}
  end

  defp start_game(board) do
    game = Game.new([])
    %{game | board: board}
  end

  defp get_non_empty_tiles(board) do
    Enum.reduce(board, [], fn row, acc ->
      acc ++ Enum.reject(row, fn tile -> tile == :empty end)
    end)
    |> List.flatten()
  end
end
