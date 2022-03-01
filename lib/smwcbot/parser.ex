defmodule SMWCBot.Parser do
  @moduledoc """
  Parser behaviour and default implementations.
  """

  @type parse_result ::
          {:ok, text :: String.t(), href :: String.t()}
          | {:ok, :multi, href :: String.t()}
          | {:ok, nil}
          | {:error, String.t()}

  @callback parse_body(String.t(), String.t(), map()) :: parse_result()

  require Logger

  defmacro __using__(_) do
    quote do
      alias SMWCBot.Parser

      @behaviour Parser

      @impl true
      def parse_body(body, search_uri, opts) do
        Parser.default_parse_body(__MODULE__, body, search_uri, opts)
      end

      def parse_result_table(result, search_uri) do
        Parser.default_parse_result_table(__MODULE__, result, search_uri)
      end

      def apply_first(result, opts) do
        Parser.default_apply_first(result, opts)
      end

      def result_to_tuple(result_href) do
        Parser.default_result_to_tuple(__MODULE__, result_href)
      end

      def build_full_uri(result_href) do
        Parser.default_build_full_uri(result_href)
      end

      def find_result(result) do
        Parser.default_find_result(__MODULE__, result)
      end

      defoverridable(
        parse_body: 3,
        parse_result_table: 2,
        find_result: 1,
        apply_first: 2,
        result_to_tuple: 1,
        build_full_uri: 1
      )
    end
  end

  def default_parse_body(mod, body, search_uri, opts) do
    case Floki.parse_document(body) do
      {:ok, document} ->
        document
        |> Floki.find("div#list_content table tr")
        |> mod.apply_first(opts)
        |> mod.parse_result_table(search_uri)

      {:error, error} ->
        Logger.error("Error parsing page: #{error}")
        {:error, "bad web page"}
    end
  end

  def default_apply_first([th, tr | _rest], %{first: true}), do: [th, tr]
  def default_apply_first(results, _opts), do: results

  def default_parse_result_table(mod, [_th, tr], _search_uri) do
    case mod.find_result(tr) do
      [result | _] -> mod.result_to_tuple(result)
      [] -> {:ok, nil}
    end
  end

  def default_parse_result_table(_mod, [_th, _tr | _], search_uri) do
    {:ok, :multi, search_uri}
  end

  def default_parse_result_table(_mod, [_th], _seatch_uri) do
    Logger.debug("Nothing")
    {:ok, nil}
  end

  def default_parse_result_table(_mod, result, _search_uri) do
    Logger.warn("No table? #{inspect(result)}")
    {:ok, nil}
  end

  def default_find_result(_mod, result) do
    Floki.find(result, "td.cell1 a")
  end

  def default_result_to_tuple(mod, result) do
    {:ok, Floki.text(result),
     result
     |> Floki.attribute("href")
     |> List.first()
     |> mod.build_full_uri()}
  end

  def default_build_full_uri(result_href) do
    "https://www.smwcentral.net#{result_href}"
  end
end
