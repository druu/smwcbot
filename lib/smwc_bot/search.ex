defmodule SMWCBot.Search do
  @moduledoc """
  Search SMWC for shit.
  """

  require Logger

  @doc """
  Search for hack.
  """
  @spec for({String.t(), String.t()}) :: {text :: String.t(), href :: String.t()} | nil
  def for({hack, waiting}) do
    base_uri = base_uri(waiting)
    filter = URI.encode_query(%{"f[name]" => hack})
    search_uri = base_uri <> filter

    Logger.debug("Uri = #{search_uri}")

    result_page = HTTPoison.get!(search_uri)

    result_page.body
    |> Floki.parse_document!()
    |> Floki.find("div#list_content table tr")
    |> parse_result_table()
  end

  defp parse_result_table([_th, tr | _]) do
    case Floki.find(tr, "td.cell1 a") do
      [result | _] -> result_to_tuple(result)
      [] -> nil
    end
  end

  defp parse_result_table([_th]) do
    Logger.debug("Nothing")
    nil
  end

  defp parse_result_table(result) do
    Logger.warn("No table? #{inspect(result)}")
    nil
  end

  defp result_to_tuple(result) do
    {Floki.text(result),
     result
     |> Floki.attribute("href")
     |> List.first()
     |> build_full_uri()}
  end

  defp build_full_uri(result_href) do
    "https://www.smwcentral.net#{result_href}"
  end

  defp base_uri("waiting"), do: "https://www.smwcentral.net/?p=section&s=smwhacks&u=1&"
  defp base_uri(_), do: "https://www.smwcentral.net/?p=section&s=smwhacks&"
end
