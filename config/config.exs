# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tz48,
  namespace: TZ48,
  ecto_repos: [TZ48.Repo]

# Configures the endpoint
config :tz48, TZ48Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zzMYi5nS+Yix4QUvSRODzjqLsV5HCwSB0YEo5y6M9fzTtK1RwGYwKc87jOGZt9w6",
  render_errors: [view: TZ48Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TZ48.PubSub,
  live_view: [signing_salt: "t3SXaRjt"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
