defmodule SMWC do
  @moduledoc """
  Search SMWC for shit.
  """

  alias SMWC.Parser
  alias SMWC.Resources

  require Logger

  @base_api_uri "https://www.smwcentral.net/ajax.php?a=getsectionlist"
  @base_search_uri "https://www.smwcentral.net/?p=section"

  @default_opts %{resource: :hack}

  @doc """
  Search for hack.
  """
  @spec search(String.t(), keyword()) :: Parser.parse_result()
  def search(query, opts \\ []) do
    opts = Enum.into(opts, @default_opts)
    filter_params = build_filter_params(query, opts)
    api_uri = "#{@base_api_uri}&#{filter_params}"
    search_uri = build_search_page_url(query, opts)

    Logger.debug("[SMWC] API URI: #{api_uri}")
    Logger.debug("[SMWC] Search URI: #{search_uri}")

    case Req.get(api_uri) do
      {:ok, %{status: 200, body: body}} ->
        json = Jason.decode!(body)
        opts.resource.parse_json_body(json, search_uri, opts)

      {:ok, %{status: status, body: body}} ->
        Logger.error("[SMWC] Error fetching page, status #{status}: #{inspect(body)}")
        {:error, to_string(status)}

      {:error, reason} ->
        Logger.error("[SMWC] Error fetching page: #{inspect(reason)}")
        {:error, inspect(reason)}
    end
  end

  def build_search_page_url(query, opts) do
    params = build_search_params(query, opts)
    "#{@base_search_uri}&#{params}"
  end

  defp build_search_params(query, opts) do
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
          Resources.Blocks -> [{"s", "smwblocks"} | acc]
          Resources.Graphics -> [{"s", "smwgraphics"} | acc]
          Resources.Hack -> [{"s", "smwhacks"} | acc]
          Resources.Music -> [{"s", "smwmusic"} | acc]
          Resources.Patches -> [{"s", "smwpatches"} | acc]
          Resources.Sprites -> [{"s", "smwsprites"} | acc]
          Resources.UberASM -> [{"s", "uberasm"} | acc]
        end

      {:waiting, true}, acc ->
        [{"u", 1} | acc]

      invalid, _acc ->
        raise ArgumentError, message: "invalid filter: #{inspect(invalid)}"
    end)
    |> Enum.reverse()
    |> URI.encode_query()
  end

  defp build_filter_params(query, opts) do
    Enum.reduce(opts, [{"f[name]", query}, {"u", 0}, {"n", 1}, {"o", "date"}, {"d", "desc"}], fn
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
          Resources.Blocks -> [{"s", "smwblocks"} | acc]
          Resources.Graphics -> [{"s", "smwgraphics"} | acc]
          Resources.Hack -> [{"s", "smwhacks"} | acc]
          Resources.Music -> [{"s", "smwmusic"} | acc]
          Resources.Patches -> [{"s", "smwpatches"} | acc]
          Resources.Sprites -> [{"s", "smwsprites"} | acc]
          Resources.UberASM -> [{"s", "uberasm"} | acc]
        end

      {:waiting, true}, acc ->
        [{"u", 1} | acc]

      invalid, _acc ->
        raise ArgumentError, message: "invalid filter: #{inspect(invalid)}"
    end)
    |> Enum.reverse()
    |> URI.encode_query()
  end
end
