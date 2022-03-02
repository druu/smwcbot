import Config

# Get a token for your bot from: https://twitchapps.com/tmi/
config :smwc, TMI,
  user: "mybotusername",
  pass: "oauth:mybotoauthtoken",
  chats: ["mychat"],
  handler: SMWCBot,
  capabilities: ['membership']
