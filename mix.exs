defmodule SMWCBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :smwcbot,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Twitch Chat Bot
      {:tmi, "~> 0.3.0"},
      # HTML Parser
      {:floki, "~> 0.31.0"},
      # HTTP Client
      {:mojito, "~> 0.7.11"}
    ]
  end
end
