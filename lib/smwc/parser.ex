defmodule SMWC.Parser do
  @moduledoc """
  Parser behaviour and default implementations for JSON API responses.
  """

  require Logger

  @base_hack_uri "https://www.smwcentral.net/?p=section&a=details&id="

  @type parse_result ::
          {:ok, text :: String.t(), href :: String.t()}
          | {:ok, :multi, href :: String.t()}
          | {:ok, nil}
          | {:error, String.t()}

  @callback parse_json_body(map(), String.t(), map()) :: parse_result()

  defmacro __using__(_) do
    quote do
      alias SMWC.Parser

      @behaviour Parser

      @impl true
      def parse_json_body(json, search_uri, opts) do
        Parser.default_parse_json_body(json, search_uri, opts)
      end

      def apply_first(data, opts) do
        Parser.default_apply_first(data, opts)
      end

      defoverridable(
        parse_json_body: 3,
        apply_first: 2
      )
    end
  end

  @spec default_parse_json_body(map(), String.t(), map()) :: parse_result()
  def default_parse_json_body(json, search_uri, opts) do
    case json do
      %{"data" => data} when is_list(data) ->
        data
        |> default_apply_first(opts)
        |> process_data(search_uri)

      _ ->
        Logger.error("[Parser] Invalid JSON response: #{inspect(json)}")
        {:error, "bad api response"}
    end
  end

  def default_apply_first([first | _rest], %{first: true}), do: [first]
  def default_apply_first(data, _opts), do: data

  defp process_data([], _search_uri) do
    Logger.debug("[Parser] No results")
    {:ok, nil}
  end

  defp process_data([item], _search_uri) do
    Logger.debug("[Parser] Single result")
    id = Map.get(item, "id")
    name = Map.get(item, "name")
    {:ok, name, "#{@base_hack_uri}#{id}"}
  end

  defp process_data([_first | _rest], search_uri) do
    Logger.debug("[Parser] Multiple results")
    {:ok, :multi, search_uri}
  end
end
