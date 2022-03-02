import Config

# Universal compile-time config.

# We set the command prefix in compile-time config because we want to match in
# function head, so we can't put it in runtime config.
config :smwcbot,
  command_prefix: "!"

config :floki, :html_parser, Floki.HTMLParser.Html5ever

# Import env-specific config, if it exists.
if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end

# Import a secret config file, if it exists.
if File.exists?("config/#{config_env()}.secret.exs") do
  import_config "#{config_env()}.secret.exs"
end
