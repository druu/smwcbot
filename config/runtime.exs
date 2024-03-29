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
config :smwc, TMI, start?: start_bot?

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
      capabilities: ['membership', 'commands', 'tags']

    config :smwc, SMWCBot,
      admin_user: System.fetch_env!("TWITCH_ADMIN_USER")
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

  config :smwc, SMWC.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: [:inet6]

  if start_server? do
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

    app_name =
      System.get_env("FLY_APP_NAME") ||
        raise "FLY_APP_NAME not available"

    host = System.get_env("PHX_HOST") || "#{app_name}.fly.dev"
    port = String.to_integer(System.get_env("PORT") || "4000")

    config :smwc, SMWCWeb.Endpoint,
      server: true,
      url: [host: host, port: 80],
      http: [
        # Enable IPv6 and bind on all interfaces.
        # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
        # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
        # for details about using IPv6 vs IPv4 and loopback vs public addresses.
        ip: {0, 0, 0, 0, 0, 0, 0, 0},
        port: port
      ],
      secret_key_base: secret_key_base
  end

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :smwc, SMWCWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :smwc, SMWC.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
