defmodule SMWCBot.MessageServer do
  @moduledoc """
  A GenServer for Sending messages at a specified rate.

  ## Options

   - `:rate` integer - The rate at which to send the messages. (one message per `rate`).
      Optional. Defaults to `30_000` ms.

  - `:messages` [{string, string}] - A list of initial messages to start with. Optional.
      Defaults to `[]`.

  """
  use GenServer, restart: :transient

  require Logger

  @default_rate_ms 30_000

  @doc """
  Start the message broadcaster.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Add a message to the outbound message queue.
  """
  @spec add_message(String.t(), String.t()) :: :ok
  def add_message(chat, message) do
    GenServer.cast(__MODULE__, {:add, {chat, message}})
  end

  ## Callbacks

  @impl true
  def init(opts) do
    state = %{
      rate: Keyword.get(opts, :rate, @default_rate_ms),
      queue: Keyword.get(opts, :messages, []) |> :queue.from_list()
    }

    Logger.info("[MessageServer] starting with a message rate of #{state.rate}ms...")

    {:ok, state, {:continue, :send}}
  end

  @impl true
  def handle_continue(:send, state) do
    send_and_schedule_next(state)
  end

  @impl true
  def handle_info(:send, state) do
    send_and_schedule_next(state)
  end

  @impl true
  def handle_cast({:add, {chat, message}}, state) do
    {:noreply, %{state | queue: :queue.in({chat, message}, state.queue)}}
  end

  ## Internal API

  # Pops a message off the queue and sends it.
  defp send_and_schedule_next(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        {:noreply, state}

      {{:value, {chat, message}}, rest} ->
        TMI.message(chat, message)
        Logger.debug("[MessageServer] sent '#{message}' to '#{chat}'")
        Process.send_after(self(), :send, state.rate)
        {:noreply, %{state | queue: rest}}
    end
  end
end
