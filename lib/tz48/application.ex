defmodule TZ48.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TZ48Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TZ48.PubSub},
      # Start the Endpoint (http/https)
      TZ48Web.Endpoint,
      {Registry, keys: :unique, name: TZ48.GameRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: TZ48.GameSupervisor}
      # Start a worker by calling: TZ48.Worker.start_link(arg)
      # {TZ48.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TZ48.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TZ48Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
