defmodule SMWCBot.Search do
  @moduledoc """
  Search SMWC for shit.
  """

  require Logger

  @base_uri "https://www.smwcentral.net/?p=section&s=smwhacks&"

  @doc """
  Search for hack.
  """
  @spec for(String.t(), keyword()) ::
          {:ok, text :: String.t(), href :: String.t()}
          | {:ok, :multi, href :: String.t()}
          | {:ok, nil}
          | {:error, String.t()}
  def for(hack, opts \\ []) do
    filter_query = build_filter_query(hack, opts) |> URI.encode_query()
    search_uri = @base_uri <> filter_query

    Logger.debug("Uri = #{search_uri}")

    case Mojito.get(search_uri) do
      {:ok, %{status_code: 200, body: body}} ->
        parse_body(body, search_uri)

      {:ok, %{status_code: status, body: body}} ->
        Logger.error("Error fetching page, status #{status}: #{inspect(body)}")
        {:error, to_string(status)}

      {:error, %{message: message}} ->
        Logger.error("Error fetching page: #{message}")
        {:error, message}
    end
  end

  defp build_filter_query(hack, opts) do
    Enum.reduce(opts, [{"f[name]", hack}], fn
      {:waiting, true}, acc ->
        [{"u", 1} | acc]

      invalid, _acc ->
        raise ArgumentError, message: "invalid filter: #{inspect(invalid)}"
    end)
  end

  defp parse_body(body, search_uri) do
    case Floki.parse_document(body) do
      {:ok, document} ->
        document
        |> Floki.find("div#list_content table tr")
        |> parse_result_table(search_uri)

      {:error, error} ->
        Logger.error("Error parsing page: #{error}")
        {:error, "bad web page"}
    end
  end

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
