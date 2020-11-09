defmodule TZ48Web.GameboardComponent do
  use TZ48Web, :live_component

  alias TZ48.Game

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <%= if @game.last_move do %>
      <p>Previous move: <%= @game.last_move %></p>
      <% else %>
      <p>&nbsp;</p>
      <% end %>
      <div class="game-board">
        <%= for {row, i} <- Enum.with_index(@game.board) do %>
          <div class="game-row d-flex flex-row">
            <%= for {col, j} <- Enum.with_index(row) do %>
              <div class="game-tile game-tile-<%= col %> <%= maybe_animate(@game.new_coords, i, j) %>"><%= if col == :empty, do: "", else: col %></div>
            <% end %>
          </div>
        <% end %>
        <%= if @game.state == :won, do: raw "<p class='game-result'>You won! <br/><a phx-click='start' class='btn btn-primary'>Start a new Game</a></p>" %>
        <%= if @game.state == :lost, do: raw "<p class='game-result'>You lost :-(<br/><a phx-click='start' class='btn btn-primary'>Don't give up. Start a new Game</a></p>" %>
      </div>
    </div>
    """
  end

  defp maybe_animate({x, y}, row, col) do
    if x == row && y == col do
      "tile-animate"
    else
      ""
    end
  end
end
