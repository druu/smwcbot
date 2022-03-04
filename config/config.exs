# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# We set the command prefix in compile-time config because we want to match in
# function head, so we can't put it in runtime config.
config :smwc, SMWCBot, command_prefix: "!"

# Set the default rate that messages will go out at.
config :smwc, SMWCBot.MessageServer, rate: 5_000

config :floki, :html_parser, Floki.HTMLParser.Html5ever

config :smwc,
  namespace: SMWC,
  ecto_repos: [SMWC.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :smwc, SMWCWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: SMWCWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SMWC.PubSub,
  live_view: [signing_salt: "v/OX0i2m"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :smwc, SMWC.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Import an environment-specific secret config file, if it exists.
if File.exists?("config/#{config_env()}.secret.exs") do
  import_config "#{config_env()}.secret.exs"
end
