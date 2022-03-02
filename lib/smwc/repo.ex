defmodule SMWC.Repo do
  use Ecto.Repo,
    otp_app: :smwc,
    adapter: Ecto.Adapters.Postgres
end
