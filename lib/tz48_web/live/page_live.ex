defmodule TZ48Web.PageLive do
  use TZ48Web, :live_view

  alias TZ48.Gameboard

  @impl true
  def mount(_params, _session, socket) do
    {board, spot} = Gameboard.get_board() |> Gameboard.start_game()

    {:ok, assign(socket, board: board, spot: spot)}
  end

  def handle_event("start", _, socket) do
    board = socket.assigns.board
    # board = Gameboard.get_board() |> Gameboard.start_game()
    {:noreply, assign(socket, :board, board)}
  end

  @delay 500 # 0.5s
  def handle_info({:move, direction}, socket) do
    board = socket.assigns.board |> Gameboard.process_move(direction)
    Process.send_after self(), :place_random_tile, @delay
    {:noreply, assign(socket, :board, board)}
  end

  def handle_info(:place_random_tile, socket) do
    {board, spot} = socket.assigns.board |> Gameboard.place_random_tile
    {:noreply, assign(socket, board: board, spot: spot)}
  end

  def handle_event("move", %{"key" => key}, socket) do
    direction = case key do
      "ArrowUp" -> :up
      "ArrowDown" -> :down
      "ArrowLeft" -> :left
      "ArrowRight" -> :right
    end
    send self(), {:move, direction}

    {:noreply, socket}
  end

  def handle_event("move", %{"direction" => direction}, socket) do
    direction = case direction do
      "up" -> :up
      "down" -> :down
      "left" -> :left
      "right" -> :right
    end
    send self(), {:move, direction}

    {:noreply, socket}
  end


  defp maybe_animate({x, y}, row, col) do
    if x == row && y == col do
      "tile-animate"
    else
      ""
    end
  end

end
