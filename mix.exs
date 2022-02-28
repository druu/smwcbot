defmodule SMWCBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :smwcbot,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SMWCBot.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Twitch Chat Bot
      {:tmi, "~> 0.3.0"},
      # HTML Parser
      {:floki, "~> 0.31.0"},
      # Alternative DOM Parser for Floki
      {:html5ever, "~> 0.11.0"},
      # HTTP Client
      {:mojito, "~> 0.7.11"},
      # Testing and static analysis
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:mimic, "~> 1.5", only: [:test]}
    ]
  end
end
