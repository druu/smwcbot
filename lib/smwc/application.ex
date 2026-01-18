defmodule SMWC.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @app :smwc

  require Logger

  @impl true
  def start(_type, _args) do
    children =
      [
        SMWCWeb.Telemetry,
        SMWC.Repo,
        {DNSCluster, query: Application.get_env(:smwc, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: SMWC.PubSub},
        # Start a worker by calling: SMWC.Worker.start_link(arg)
        # {SMWC.Worker, arg},
        # Start to serve requests, typically the last entry
        SMWCWeb.Endpoint,
        # Dynamic supervisor, for one-off stuff.
        {SMWCBot.MessageServer, module_config(SMWCBot.MessageServer)},
        # Cooldown Queue
        {SMWCBot.Fridge, %{}}
      ]
      |> add_tmi_childspec()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SMWC.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update to endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SMWCWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp add_tmi_childspec(children) do
    if tmi_start?() do
      Logger.info("[TMI] Starting Twitch chat connection...")
      [{TMI.Supervisor, module_config(TMI)} | children]
    else
      Logger.warning("[TMI] Skipping start of Twitch chat...")
      Logger.info("[TMI] To start Twitch chat use TMI_START=true")
      children
    end
  end

  # Get the start? flag from TMI config to decide whether to start TMI
  defp tmi_start? do
    tmi_config = Application.get_env(:smwc, TMI, [])
    Keyword.get(tmi_config, :start?, false)
  end

  # Get module config.
  defp module_config(module, opts \\ []) do
    if Keyword.get(opts, :required) do
      Application.fetch_env!(@app, module)
    else
      Application.get_env(@app, module, [])
    end
  end
end
