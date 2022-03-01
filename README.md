# SMWCBot

[![CI](https://github.com/druu/smwcbot/actions/workflows/ci.yml/badge.svg)](https://github.com/druu/smwcbot/actions/workflows/ci.yml)

Twitch chat bot for searching SMW Central.
### Running locally

 * Copy `config/config.secret.example.exs` to `config/config.secret.exs`.
 * Update the config file with your bot's config. Channel names should be lowercase.

```sh
TMI_START=true iex -S mix
```

### Twitch chat examples

*The following assumes default command prefix of `!`.*

```
jim> !hack redeeming peach
thebot> Here jim, Redeeming Peach @ https://www.smwcentral.net/?p=section&a=details&id=10173
```

### Deploying

*TODO* For now, try looking at `config/runtime.exs` and figuring the rest out on your own.
