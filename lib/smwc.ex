defmodule SMWC do
  @moduledoc """
  Search SMWC for shit.
  """

  alias SMWC.Parser

  require Logger

  alias SMWC.Resources

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
        opts.resource.parse_body(body, search_uri, opts)

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
          Resources.Block -> [{"p", "section"}, {"s", "smwblocks"} | acc]
          Resources.Graphics -> [{"p", "section"}, {"s", "smwgraphics"} | acc]
          Resources.Hack -> [{"p", "section"}, {"s", "smwhacks"} | acc]
          Resources.Music -> [{"p", "section"}, {"s", "smwmusic"} | acc]
          Resources.Patch -> [{"p", "section"}, {"s", "smwpatches"} | acc]
          Resources.Sprite -> [{"p", "section"}, {"s", "smwsprites"} | acc]
          Resources.UberASM -> [{"p", "section"}, {"s", "uberasm"} | acc]
        end

      {:waiting, true}, acc ->
        [{"u", 1} | acc]

      invalid, _acc ->
        raise ArgumentError, message: "invalid filter: #{inspect(invalid)}"
    end)
  end
end
