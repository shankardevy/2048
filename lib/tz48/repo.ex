defmodule TZ48.Repo do
  use Ecto.Repo,
    otp_app: :tz48,
    adapter: Ecto.Adapters.Postgres
end
