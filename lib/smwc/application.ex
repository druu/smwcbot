defmodule SMWC.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @app :smwc

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Ecto repository
        SMWC.Repo,
        # Start the Telemetry supervisor
        SMWCWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: SMWC.PubSub},
        # Start the Endpoint (http/https)
        SMWCWeb.Endpoint
        # Start a worker by calling: SMWC.Worker.start_link(arg)
        # {SMWC.Worker, arg}
      ]
      |> add_tmi_childspec()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SMWC.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SMWCWeb.Endpoint.config_change(changed, removed)
    :ok
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
