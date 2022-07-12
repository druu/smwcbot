defmodule SMWC.Resources.Music do
  @moduledoc false
  use SMWC.Parser

  def find_result(result) do
    Floki.find(result, "td.text > a")
  end
end
