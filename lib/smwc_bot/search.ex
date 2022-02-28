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
    search_uri = "#{base_uri}#{filter}"

    Logger.debug("Uri = #{search_uri}")

    result_page = HTTPoison.get!("#{base_uri}#{filter}")

    result_page.body
    |> Floki.parse_document!()
    |> Floki.find("div#list_content table tr")
    |> parse_result_table()
  end

  defp parse_result_table([_, table]) do
    case Floki.find(table, "td.cell1 a") do
      [result | _] ->
        {Floki.text(result), Floki.attribute(result, "href") |> List.first() |> build_full_uri()}

      [] ->
        nil
    end
  end

  defp parse_result_table([_]) do
    Logger.debug('Nothing')
    nil
  end

  defp parse_result_table(_) do
    nil
  end

  defp build_full_uri(result_href) do
    "https://www.smwcentral.net#{result_href}"
  end

  defp base_uri("waiting"), do: "https://www.smwcentral.net/?p=section&s=smwhacks&u=1&"
  defp base_uri(_), do: "https://www.smwcentral.net/?p=section&s=smwhacks&"
end
