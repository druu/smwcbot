defmodule SMWCBot.Search do
  @moduledoc """
  Search SMWC for shit.
  """

  alias SMWCBot.Parser

  require Logger

  @base_uri "https://www.smwcentral.net"

  @default_opts %{resource: :hack}

  @doc """
  Search for hack.
  """
  @spec for(String.t(), keyword()) :: Parser.parse_result()
  def for(query, opts \\ []) do
    opts = Enum.into(opts, @default_opts)
    filter_params = build_filter_params(query, opts) |> URI.encode_query()
    search_uri = "#{@base_uri}/?#{filter_params}"

    Logger.debug("Uri = #{search_uri}")

    case Mojito.get(search_uri) do
      {:ok, %{status_code: 200, body: body}} ->
        opts.resource
        |> parser_from_resource()
        |> then(& &1.parse_body(body, search_uri, opts))

      {:ok, %{status_code: status, body: body}} ->
        Logger.error("Error fetching page, status #{status}: #{inspect(body)}")
        {:error, to_string(status)}

      {:error, %{message: message}} ->
        Logger.error("Error fetching page: #{message}")
        {:error, message}
    end
  end

  defp build_filter_params(query, opts) do
    Enum.reduce(opts, [{"f[name]", query}], fn
      {:resource, resource}, acc ->
        case resource do
          :hack -> [{"p", "section"}, {"s", "smwhacks"} | acc]
          :music -> [{"p", "section"}, {"s", "smwmusic"} | acc]
          :graphics -> [{"p", "section"}, {"s", "smwgraphics"} | acc]
          :blocks -> [{"p", "section"}, {"s", "smwblocks"} | acc]
        end

      {:waiting, true}, acc ->
        [{"u", 1} | acc]

      {:order, order}, acc ->
        case String.split(order, ":", parts: 2, trim: true) do
          [col] -> [{"o", col}, {"d", "desc"} | acc]
          [col, dir] -> [{"o", col}, {"d", dir} | acc]
        end

      {:first, true}, acc ->
        acc

      invalid, _acc ->
        raise ArgumentError, message: "invalid filter: #{inspect(invalid)}"
    end)
  end

  defp parser_from_resource(:blocks), do: SMWCBot.BlocksParser
  defp parser_from_resource(:graphics), do: SMWCBot.GraphicsParser
  defp parser_from_resource(:hack), do: SMWCBot.HacksParser
  defp parser_from_resource(:music), do: SMWCBot.MusicParser
end
