defmodule SMWC.Resources.Music do
  @moduledoc false
  use SMWC.Parser

  def find_result(result) do
    Floki.find(result, "td.cell1 .cell-icon-aside a")
  end
end
