import Config

# Set the default rate that messages will go out at for DEV.
config :smwc, SMWCBot.MessageServer, rate: 5000

# Get a token for your bot from: https://twitchapps.com/tmi/
config :smwc, TMI,
  bot: SMWCBot,
  user: "mybotusername",
  pass: "oauth:mybotoauthtoken",
  channels: ["mychat"],
  capabilities: ['membership', 'commands', 'tags']

config :smwc, SMWCBot,
  admin_user: "yournamehere"
