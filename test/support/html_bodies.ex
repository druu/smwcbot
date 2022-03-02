defmodule SMWC.HTMLBodies do
  @moduledoc """
  HTML page bodies.
  """

  def smwc_results(resource, amount) do
    "./data/#{resource}/#{amount}-results.txt"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> Base.decode64!()
  end
end
