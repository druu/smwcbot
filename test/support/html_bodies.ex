defmodule SMWCBot.HTMLBodies do
  @moduledoc """
  HTML page bodies.
  """

  def smwc_results(amount) do
    "./data/#{amount}-results.txt"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> Base.decode64!()
  end
end
