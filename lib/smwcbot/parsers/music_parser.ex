defmodule SMWCBot.MusicParser do
  @moduledoc false
  use SMWCBot.Parser

  def find_result(result) do
    Floki.find(result, "td.cell1 .cell-icon-aside a")
  end
end
