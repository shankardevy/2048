defmodule TZ48Web.GameLive do
  use TZ48Web, :live_view

  alias TZ48.GameServer
  alias TZ48.Game

  @impl true
  def mount(params, _session, socket) do
    socket =
      case params["id"] do
        nil ->
          game_id = UUID.uuid4()
          push_redirect(socket, to: Routes.game_path(socket, :play, game_id))

        _ ->
          socket
      end

    {:ok, assign(socket, spot: {1, 1}, game: nil)}
  end

  @impl true
  def handle_params(%{"id" => game_id}, _uri, socket) do
    {:ok, game_server} =
      DynamicSupervisor.start_child(
        MyApp.DynamicSupervisor,
        {TZ48.GameServer, [game_id: game_id, player: self()]}
      )

    socket = assign(socket, game_server: game_server, game_id: game_id)

    {:noreply, socket}
  end

  @doc """
  Start the game.
  """
  @impl true
  def handle_event("start", _, socket) do
    game = socket.assigns.game_server |> GameServer.start_game()

    {:noreply, assign(socket, game: game)}
  end

  @doc """
  Handle keyboard direction key events
  """
  @impl true
  def handle_event("move", %{"key" => key}, socket) do
    direction =
      case key do
        "ArrowUp" -> :up
        "ArrowDown" -> :down
        "ArrowLeft" -> :left
        "ArrowRight" -> :right
      end

    send(self(), {:move, direction})

    {:noreply, socket}
  end

  @doc """
  Handle button click events.
  """
  @impl true
  def handle_event("move", %{"direction" => direction}, socket) do
    direction =
      case direction do
        "up" -> :up
        "down" -> :down
        "left" -> :left
        "right" -> :right
      end

    send(self(), {:move, direction})

    {:noreply, socket}
  end

  @doc """
  Handles the message from LV whenever a direction key or button is pressed.
  """
  # 0.5s
  @delay 500
  @impl true
  def handle_info({:move, direction}, socket) do
    game = socket.assigns.game_server |> GameServer.process_move(direction)
    Process.send_after(self(), :place_random_tile, @delay)
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info(:place_random_tile, socket) do
    game = socket.assigns.game_server |> GameServer.place_random_tile()
    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def terminate(reason, _socket) do
    IO.inspect(reason)
  end

  defp maybe_animate({x, y}, row, col) do
    if x == row && y == col do
      "tile-animate"
    else
      ""
    end
  end
end
