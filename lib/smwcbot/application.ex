defmodule SMWCBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @app :smwcbot

  @impl true
  def start(_type, _args) do
    children =
      [
        # Starts a worker by calling: SMWCBot.Worker.start_link(arg)
        # {SMWCBot.Worker, arg}
      ]
      |> add_tmi_childspec()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SMWCBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp add_tmi_childspec(children) do
    tmi_config = Application.get_env(@app, TMI, [])
    {start?, tmi_config} = Keyword.pop(tmi_config, :start?)

    if start? do
      Logger.info("[TMI] Starting Twitch chat connection...")
      [{TMI.Supervisor, tmi_config} | children]
    else
      Logger.warn("[TMI] Skipping start of Twitch chat...")
      Logger.info("[TMI] To start Twitch chat use TMI_START=true")
      children
    end
  end
end
