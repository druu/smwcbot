# SMWCBot

[![CI](https://github.com/druu/smwcbot/actions/workflows/ci.yml/badge.svg)](https://github.com/druu/smwcbot/actions/workflows/ci.yml)

Twitch chat bot for searching SMW Central.
### Running locally

 * Copy `config/dev.secret.example.exs` to `config/dev.secret.exs`.
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

#### Available commands
* !hack \<name>
* !graphics \<name>
* !blocks \<name>
* !sprites \<name>
* !music \<name>
* !patches \<name>
* !uberasm \<name> or !asm \<name>

#### Available filters
* `-a, --author` - Enables the search by author
  * `jim> !hack --author lush_50`
* `-f, --first` - Returns the first result from multiple results
  * `jim> !hack -f mario`
* `-o, --order \<field>:[asc|desc]` - Enables Result sorting(:asc, :desc), defaults to descending 
  * `jim> !hack -f -o rating:asc mario` will give you a hack with "mario" in its name and the lowest rating
* `-w, -waiting`  searches the waiting list
  * `jim> !hack --waiting mario`
 
 
### Deploying

*TODO* For now, try looking at `config/runtime.exs` and figuring the rest out on your own.
