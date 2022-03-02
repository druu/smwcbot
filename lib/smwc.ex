defmodule SMWC do
  @moduledoc """
  Search SMWC for shit.
  """

  alias SMWC.Parser

  require Logger

  @base_uri "https://www.smwcentral.net"

  @default_opts %{resource: :hack}

  @doc """
  Search for hack.
  """
  @spec search(String.t(), keyword()) :: Parser.parse_result()
  def search(query, opts \\ []) do
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
      {:author, name}, acc ->
        [{"f[author]", name} | acc]

      {:first, true}, acc ->
        acc

      {:order, order}, acc ->
        case String.split(order, ":", parts: 2, trim: true) do
          [col] -> [{"o", col}, {"d", "desc"} | acc]
          [col, dir] -> [{"o", col}, {"d", dir} | acc]
        end

      {:resource, resource}, acc ->
        case resource do
          :asm -> [{"p", "section"}, {"s", "uberasm"} | acc]
          :blocks -> [{"p", "section"}, {"s", "smwblocks"} | acc]
          :graphics -> [{"p", "section"}, {"s", "smwgraphics"} | acc]
          :hack -> [{"p", "section"}, {"s", "smwhacks"} | acc]
          :music -> [{"p", "section"}, {"s", "smwmusic"} | acc]
          :patches -> [{"p", "section"}, {"s", "smwpatches"} | acc]
          :sprites -> [{"p", "section"}, {"s", "smwsprites"} | acc]
          :uberasm -> [{"p", "section"}, {"s", "uberasm"} | acc]
        end

      {:waiting, true}, acc ->
        [{"u", 1} | acc]

      invalid, _acc ->
        raise ArgumentError, message: "invalid filter: #{inspect(invalid)}"
    end)
  end

  defp parser_from_resource(:asm), do: SMWC.UberASMParser
  defp parser_from_resource(:blocks), do: SMWC.BlocksParser
  defp parser_from_resource(:graphics), do: SMWC.GraphicsParser
  defp parser_from_resource(:hack), do: SMWC.HacksParser
  defp parser_from_resource(:music), do: SMWC.MusicParser
  defp parser_from_resource(:patches), do: SMWC.PatchesParser
  defp parser_from_resource(:sprites), do: SMWC.SpritesParser
  defp parser_from_resource(:uberasm), do: SMWC.UberASMParser
end
