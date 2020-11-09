defmodule TZ48.GameServer do
  use GenServer

  alias TZ48.Game

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def start_game(pid) do
    GenServer.call(pid, :start)
  end

  def join_game(pid, player_pid) do
    GenServer.call(pid, {:join, player_pid})
  end

  def exit_game(pid, player_pid) do
    GenServer.call(pid, {:exit, player_pid})
  end

  def get_game(pid) do
    GenServer.call(pid, :get)
  end

  def process_move(pid, direction) do
    GenServer.call(pid, {:move, direction})
  end

  def place_random_tile(pid) do
    GenServer.call(pid, :place_random_tile)
  end

  def add_message(pid, message) do
    GenServer.cast(pid, {:message, message})
  end

  # Callbacks

  @impl true
  def init(opts) do
    game = Game.new(opts)
    {:ok, game}
  end

  @impl true
  def handle_call(:start, _from, game) do
    game = Game.start_game(game)
    {:reply, game, game}
  end

  @impl true
  def handle_call(:get, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_call({:join, pid}, _from, game) do
    game = Game.join(game, pid)

    {:reply, game, game}
  end

  @impl true
  def handle_call({:exit, pid}, _from, game) do
    game = Game.exit(game, pid)

    {:reply, game, game}
  end

  @impl true
  def handle_call({:move, direction}, _from, game) do
    game = Game.process_move(game, direction)

    {:reply, game, game}
  end

  def handle_call(:place_random_tile, _from, game) do
    game = Game.place_random_tile(game)

    {:reply, game, game}
  end

  def handle_cast({:message, message}, game) do
    game = Game.add_message(game, message)

    {:noreply, game}
  end
end
