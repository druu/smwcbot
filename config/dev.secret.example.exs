import Config

# Set the default rate that messages will go out at for DEV.
config :smwc, SMWCBot.MessageServer, rate: 5_000

# Get a token for your bot from: https://twitchapps.com/tmi/
config :smwc, TMI,
  user: "mybotusername",
  pass: "oauth:mybotoauthtoken",
  chats: ["mychat"],
  handler: SMWCBot,
  capabilities: ['membership']
