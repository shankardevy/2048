defmodule TZ48Web.GameLive do
  use TZ48Web, :live_view

  alias Phoenix.PubSub
  alias TZ48.GameServer
  alias TZ48.Game

  @impl true
  def mount(params, _session, socket) do
    socket =
      case params["id"] do
        nil ->
          game_id = UUID.uuid4()
          {:ok, _game_server_pid} =
            DynamicSupervisor.start_child(
              TZ48.GameSupervisor,
              {GameServer, [name: game_pid(game_id), player: self()]}
            )
          push_redirect(socket, to: Routes.game_path(socket, :play, game_id))

        _ ->
          socket
      end

    {:ok, assign(socket, spot: {1, 1}, game: nil)}
  end

  @impl true
  def handle_params(%{"id" => game_id}, _uri, socket) do
    game_pid = get_game_pid(game_id)

    game = if game_pid do
      GameServer.start_game(game_pid)
    end

    if socket.connected?, do: PubSub.subscribe TZ48.PubSub, "game:#{game_id}"

    socket = assign(socket, game: game, game_pid: game_pid, game_id: game_id)

    {:noreply, socket}
  end

  @doc """
  Start the game.
  """
  @impl true
  def handle_event("start", _, socket) do
    game_pid = socket.assigns.game_pid
    game = GameServer.start_game(game_pid)

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

    send self(), {:move, direction}

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

    send self(), {:move, direction}

    {:noreply, socket}
  end

  @doc """
  Handles the message from LV whenever a direction key or button is pressed.
  """
  # 0.5s
  @delay 500
  @impl true
  def handle_info({:move, direction}, socket) do
    game_pid = socket.assigns.game_pid
    game_id = socket.assigns.game_id
    game = GameServer.process_move(game_pid, direction)

    PubSub.broadcast TZ48.PubSub, "game:#{game_id}", :sync_board

    Process.send_after(self(), :place_random_tile, @delay)
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info(:place_random_tile, socket) do
    game_id = socket.assigns.game_id
    game = socket.assigns.game_pid |> GameServer.place_random_tile()

    PubSub.broadcast TZ48.PubSub, "game:#{game_id}", :sync_board

    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def handle_info(:sync_board, socket) do
    game_pid = socket.assigns.game_pid
    game = GameServer.get_game(game_pid)

    {:noreply, assign(socket, :game, game)}
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

  defp get_game_pid(game_id) do
    case Registry.lookup(TZ48.GameRegistry, game_id) do
      [{pid, nil}] -> pid
      _ -> nil
    end
  end

  defp game_pid(id) do
    {:via, Registry, {TZ48.GameRegistry, id}}
  end

end
