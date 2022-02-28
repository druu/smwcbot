# COMPILE-TIME CONFIG
import Config

config :smwcbot,
  command_prefix: "!"

# Import a secret config file, if it exists.
if File.exists?("config/config.secret.exs") do
  import_config "config.secret.exs"
end
