defmodule SMWCBot.BlocksParser do
  @moduledoc false
  @behaviour SMWCBot.Parser

  require Logger

  @impl true
  def parse_body(body, search_uri, opts) do
    case Floki.parse_document(body) do
      {:ok, document} ->
        document
        |> Floki.find("div#list_content table tr")
        |> apply_first(opts)
        |> parse_result_table(search_uri)

      {:error, error} ->
        Logger.error("Error parsing page: #{error}")
        {:error, "bad web page"}
    end
  end

  defp apply_first([th, tr | _rest], %{first: true}), do: [th, tr]
  defp apply_first(results, _opts), do: results

  defp parse_result_table([_th, tr], _search_uri) do
    case Floki.find(tr, "td.cell1 a") do
      [result | _] -> result_to_tuple(result)
      [] -> {:ok, nil}
    end
  end

  defp parse_result_table([_th, _tr | _], search_uri) do
    {:ok, :multi, search_uri}
  end

  defp parse_result_table([_th], _seatch_uri) do
    Logger.debug("Nothing")
    {:ok, nil}
  end

  defp parse_result_table(result, _search_uri) do
    Logger.warn("No table? #{inspect(result)}")
    {:ok, nil}
  end

  defp result_to_tuple(result) do
    {:ok, Floki.text(result),
     result
     |> Floki.attribute("href")
     |> List.first()
     |> build_full_uri()}
  end

  defp build_full_uri(result_href) do
    "https://www.smwcentral.net#{result_href}"
  end
end
