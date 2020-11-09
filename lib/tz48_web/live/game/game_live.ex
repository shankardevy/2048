defmodule TZ48Web.GameLive do
  use TZ48Web, :live_view

  alias Phoenix.PubSub
  alias TZ48.GameServer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, autoplay: false, game: nil, game_id: nil)}
  end

  @impl true
  def handle_params(%{"id" => game_id}, _uri, socket) do
    game_pid = get_game_pid(game_id)

    game =
      cond do
        socket.connected? && game_pid ->
          PubSub.subscribe(TZ48.PubSub, "game:#{game_id}")
          game = GameServer.join_game(game_pid, self())
          PubSub.broadcast(TZ48.PubSub, "game:#{game_id}", :sync_board)
          game

        game_pid ->
          GameServer.get_game(game_pid)

        true ->
          nil
      end

    socket = assign(socket, game: game, game_pid: game_pid, game_id: game_id)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @doc """
  Start the game.
  """
  @impl true
  def handle_event("start", _, socket) do
    game_id = UUID.uuid4()

    {:ok, pid} =
      DynamicSupervisor.start_child(
        TZ48.GameSupervisor,
        {GameServer, [id: game_id, name: game_pid(game_id)]}
      )

    GameServer.start_game(pid)

    {:noreply, push_patch(socket, to: Routes.game_path(socket, :play, game_id))}
  end

  @doc """
  Toggles the autoplay feature of the game.
  """
  @impl true
  def handle_event("autoplay", _, socket) do
    autoplay = socket.assigns.autoplay
    socket = assign(socket, autoplay: !autoplay)

    # autoplay store the previous state, so if it's true, then it's false now.
    if !autoplay, do: send(self(), :autoplay)

    {:noreply, socket}
  end

  @doc """
  Set gamemode.
  """
  @impl true
  def handle_event("mode", %{"mode" => _mode}, socket) do
    {:noreply, socket}
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
  Handle incoming chat messages.
  """
  @impl true
  def handle_event("send", %{"message" => message}, socket) do
    message = "#{inspect(self())}: #{message}"
    game_id = socket.assigns.game_id
    game_pid = socket.assigns.game_pid
    GameServer.add_message(game_pid, message)

    PubSub.broadcast(TZ48.PubSub, "game:#{game_id}", :sync_board)
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

    PubSub.broadcast(TZ48.PubSub, "game:#{game_id}", :sync_board)

    if game.state == :continue, do: Process.send_after(self(), :place_random_tile, @delay)
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info(:place_random_tile, socket) do
    game_id = socket.assigns.game_id
    game = socket.assigns.game_pid |> GameServer.place_random_tile()

    PubSub.broadcast(TZ48.PubSub, "game:#{game_id}", :sync_board)

    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def handle_info(:sync_board, socket) do
    game_pid = socket.assigns.game_pid
    game = GameServer.get_game(game_pid)

    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info(:autoplay, socket) do
    game_pid = socket.assigns.game_pid
    possible_moves = [:left, :right, :up, :down]
    direction = Enum.random(possible_moves)
    game = GameServer.get_game(game_pid)

    send(self(), {:move, direction})

    if game.state == :continue && socket.assigns.autoplay,
      do: Process.send_after(self(), :autoplay, 1500)

    {:noreply, socket}
  end

  @impl true
  def terminate(reason, socket) do
    case reason do
      {:shutdown, :closed} ->
        game_pid = socket.assigns.game_pid
        game = GameServer.exit_game(game_pid, self())

        if Enum.count(game.players) == 0 do
          [{pid, nil}] = Registry.lookup(TZ48.GameRegistry, socket.assigns.game_id)

          DynamicSupervisor.terminate_child(
            TZ48.GameSupervisor,
            pid
          )
        end

      _ ->
        :ok
    end
  end

  defp get_game_pid(game_id) do
    case Registry.lookup(TZ48.GameRegistry, game_id) do
      [{_pid, nil}] -> game_pid(game_id)
      _ -> nil
    end
  end

  defp game_pid(game_id) do
    {:via, Registry, {TZ48.GameRegistry, game_id}}
  end
end
