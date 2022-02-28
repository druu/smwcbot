# RUNTIME CONFIG
import Config

# To start the TMI connection, start your application with `TMI_START=true`.
#
# ## Example in `:dev`:
#
#     $ TMI_START=true iex -S mix
#
config :smwcbot, TMI, start?: String.downcase(System.get_env("TMI_START", "")) == "true"

# Production Runtime config with environment variables.
if config_env() == :prod do
  config :smwcbot, TMI,
    user: System.fetch_env!("TWITCH_USER"),
    pass: System.fetch_env!("TWITCH_TOKEN"),
    chats:
      System.fetch_env!("TWITCH_CHATS")
      |> String.split(~r/,\s*/, trim: true)
      |> Enum.map(&String.downcase/1),
    handler: SMWCBot,
    capabilities: ['membership']
end
