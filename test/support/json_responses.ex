defmodule SMWC.JSONResponses do
  @moduledoc """
  JSON API response bodies.
  """

  def smwc_results(resource, type) do
    path = ".api_results/#{resource}_results.json"
    File.read!(path) |> Jason.decode!()
  end

  def single_result do
    ".api_results/single_result.json"
    |> File.read!()
    |> Jason.decode!()
  end

  def multiple_results do
    ".api_results/multiple_results.json"
    |> File.read!()
    |> Jason.decode!()
  end
end
