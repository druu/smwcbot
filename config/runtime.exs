import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

start_bot? = String.downcase(System.get_env("TMI_START", "")) == "true"
start_server? = System.get_env("PHX_SERVER", "") == "true"

# To start the TMI connection, start your application with `TMI_START=true`.
#
# ## Example in `:dev`:
#
#     $ TMI_START=true iex -S mix
#
config :smwc, TMI,
  start?: start_bot?,
  bot: SMWCBot

# Add dummy user/pass for dev/test mode to satisfy TMI requirements
if config_env() == :dev or config_env() == :test do
  config :smwc, TMI,
    user: "dev_user",
    pass: "dev_token",
    channels: ["#dev"],
    capabilities: [~c'membership', ~c'commands', ~c'tags']
end

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/smwc start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if start_server? do
  config :smwc, SMWCWeb.Endpoint, server: true
end

config :smwc, SMWCWeb.Endpoint, http: [port: String.to_integer(System.get_env("PORT", "4000"))]

if config_env() == :prod do
  if start_bot? do
    config :smwc, TMI,
      user: System.fetch_env!("TWITCH_USER"),
      pass: System.fetch_env!("TWITCH_TOKEN"),
      channels:
        System.fetch_env!("TWITCH_CHANNELS")
        |> String.split(~r/,\s*/, trim: true)
        |> Enum.map(&String.downcase/1),
      bot: SMWCBot,
      capabilities: [~c'membership', ~c'commands', ~c'tags']

    config :smwc, SMWCBot, admin_user: System.fetch_env!("TWITCH_ADMIN_USER")
  end

  # Set the rate that Twitch messages will go out at. This will vary based on
  # whether or not you are the broadcaster, are a mod, or have a verified bot.
  config :smwc, SMWCBot.MessageServer,
    rate: System.get_env("TWITCH_MSG_RATE", "1500") |> String.to_integer()

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :smwc, SMWC.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    # For machines with several cores, consider starting multiple pools of `pool_size`
    # pool_count: 4,
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"

  config :smwc, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :smwc, SMWCWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0}
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :smwc, SMWCWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :smwc, SMWCWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Here is an example configuration for Mailgun:
  #
  #     config :smwc, SMWC.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # Most non-SMTP adapters require an API client. Swoosh supports Req, Hackney,
  # and Finch out-of-the-box. This configuration is typically done at
  # compile-time in your config/prod.exs:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Req
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
