# COMPILE-TIME CONFIG
import Config

config :smwcbot,
  command_prefix: "!"

config :floki, :html_parser, Floki.HTMLParser.Html5ever

# Import env-specific config, if it exists.
if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end

# Import a secret config file, if it exists.
if File.exists?("config/config.secret.exs") do
  import_config "config.secret.exs"
end
