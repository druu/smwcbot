defmodule SMWCBot.MusicParser do
  @moduledoc false
  @behaviour SMWCBot.Parser

  @impl true
  def parse_body(_body, _search_uri, _resource, _first?) do
    {:error, "Not implemented"}
  end
end
