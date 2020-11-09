defmodule TZ48Web.GameControlComponent do
  use TZ48Web, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <button phx-click="autoplay" class="mb-2 btn btn-primary"><%= if @autoplay, do: "Stop auto play", else: "Start auto play" %></button>
    <div class="ml-auto keys">
      <div class="d-flex flex-row justify-content-center">
        <div phx-window-keydown="move" phx-key="ArrowUp" phx-throttle="500" phx-click="move" phx-value-direction="up" class="ctrl-key">↑</div>
      </div>
      <div class="d-flex flex-row justify-content-center">
        <div phx-window-keydown="move" phx-key="ArrowLeft" phx-throttle="500" phx-click="move" phx-value-direction="left" class="ctrl-key">←</div>
        <div phx-window-keydown="move" phx-key="ArrowDown" phx-throttle="500" phx-click="move" phx-value-direction="down" class="ctrl-key">↓</div>
        <div phx-window-keydown="move" phx-key="ArrowRight" phx-throttle="500" phx-click="move" phx-value-direction="right" class="ctrl-key">→</div>
      </div>
    </div>
    """
  end
end
