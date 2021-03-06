defmodule SMWCBot.MessageServer do
  @moduledoc """
  A GenServer for Sending messages at a specified rate.

  ## Options

   - `:rate` (integer) - The rate at which to send the messages. (one message
      per `rate`). Optional. Defaults to `1500` ms.

  ### Twitch command and message rate limits:

  If command and message rate limits are exceeded, an application cannot send chat
  messages or commands for 30 minutes.

  | Limit                         | Applies to
  |-------------------------------|---------------------------------------------
  | 20 per 30 seconds             | Users sending commands or messages to
  |                               | channels in which they are not the broadcaster
  |                               | and do not have Moderator status.
  | 100 per 30 seconds 	          | Users sending commands or messages to channels
  |                               | in which they are the broadcaster or have
  |                               | Moderator status.
  | 7500 per 30 seconds           | Verified bots. The channel limits above also
  | site-wide                     | apply. In other words, one of the two limits
  |                               | above will also be applied depending on
  |                               | whether the verified bot is the broadcaster
  |                               | or has Moderator status.

  https://dev.twitch.tv/docs/irc/guide#rate-limits

  """
  use GenServer

  require Logger

  @default_rate_ms 1500

  @doc """
  Start the message server.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
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
      timer_ref: nil,
      queue: :queue.new()
    }

    Logger.info("[MessageServer] STARTING with a message rate of #{state.rate}ms...")

    {:ok, state}
  end

  @impl true
  # If there is no timer_ref, then that means the queue was empty and paused, so
  # we will add it to the queue and start it again.
  def handle_cast({:add, chat_message}, %{timer_ref: nil} = state) do
    send_and_schedule_next(%{state | queue: :queue.in(chat_message, state.queue)})
  end

  # The timer_ref was not empty so that means the queue is running, so we will
  # just add the message to queue.
  def handle_cast({:add, chat_message}, state) do
    {:noreply, %{state | queue: :queue.in(chat_message, state.queue)}}
  end

  @impl true
  def handle_info(:send, state) do
    send_and_schedule_next(state)
  end

  ## Internal API

  # Pops a message off the queue and sends it.
  defp send_and_schedule_next(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        Logger.debug("[MessageServer] no more messages to send: PAUSED")
        {:noreply, %{state | timer_ref: nil}}

      {{:value, {chat, message}}, rest} ->
        TMI.message(chat, message)
        Logger.debug("[MessageServer] SENT #{chat}: #{message}")
        timer_ref = Process.send_after(self(), :send, state.rate)
        {:noreply, %{state | queue: rest, timer_ref: timer_ref}}
    end
  end
end
