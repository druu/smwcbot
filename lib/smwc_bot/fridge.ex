defmodule SMWCBot.Fridge do
  @moduledoc """
  Handles command cooldown
  """

  use GenServer

  require Logger

  @ttl_seconds 60


  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def insert(map) when is_map(map) do
    map_to_sha256(map)
    |> insert()
  end

  def insert(hash) when is_bitstring(hash) do
    GenServer.cast(__MODULE__, {:insert, %{:key => hash, :val => NaiveDateTime.utc_now() }})
  end

  def upsert(map) when is_map(map) do
    map_to_sha256(map)
    |> upsert()
  end

  def upsert(hash) when is_bitstring(hash) do
    if is_expired?(hash) do
      remove(hash)
      insert(hash)
    end
  end

  def is_expired?(map) when is_map(map) do
    map_to_sha256(map)
    |> is_expired?()
  end

  def is_expired?(hash) when is_bitstring(hash) do
    case Map.has_key?(get_contents(), hash) do
      true -> diff_from_element(hash) + @ttl_seconds <= 0
      _ -> true
    end
  end

  defp diff_from_element(map) when is_map(map) do
    map_to_sha256(map)
    |> diff_from_element()
  end

  defp diff_from_element(hash) when is_bitstring(hash) do
    get_contents()
    |> Map.get(hash, NaiveDateTime.utc_now())
    |> NaiveDateTime.diff(NaiveDateTime.utc_now())
  end

  def get_contents() do
    GenServer.call(__MODULE__, :contents)
  end

  def remove(map) when is_map(map) do
    map_to_sha256(map)
    |> remove()
  end

  def remove(hash) when is_bitstring(hash) do
    if Map.has_key?(get_contents(), hash) do
      GenServer.call(__MODULE__, {:delete, hash})
    end
  end

  defp map_to_sha256(map) do
    map
    |> Enum.map(fn {k, v} -> [to_string(k), to_string(v)] end)
    |> IO.iodata_to_binary()
    |> string_to_sha256()
  end

  defp string_to_sha256(str) do
    :crypto.hash(:sha256, str)
    |> Base.encode16(case: :lower)
  end


  ## Server Callbacks
  @impl true
  def init(contents) do
    Logger.info("[MessageServer] STARTING Cooldown Fridge...")
    {:ok, contents}
  end

  @impl true
  def handle_cast({:insert, element}, contents) do
    {:noreply, Map.put(contents, element.key, element.val)}
  end

  @impl true
  def handle_call(:contents, _, contents) do
    {:reply, contents, contents}
  end

  @impl true
  def handle_call({:delete, hash}, _from, contents) do
    {:reply, Map.fetch(contents, hash), Map.delete(contents, hash)}
  end


end
