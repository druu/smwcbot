defmodule SMWCBot do
  @moduledoc """
  Main bot handler.
  """
  use TMI.Handler

  alias SMWCBot.Search

  require Logger

  @command_prefix Application.compile_env(:smwcbot, :command_prefix, "!")

  @impl true
  def handle_message(@command_prefix <> command, sender, chat) do
    case search_hack(command) do
      {:ok, :multi, href} ->
        TMI.message(chat, "Here #{sender}, I found multiple results @ #{href}")

      {:ok, text, href} ->
        TMI.message(chat, "Here #{sender}, #{text} @ #{href}")

      {:ok, nil} ->
        TMI.message(chat, "Sorry #{sender}, no results")

      {:error, reason} ->
        TMI.message(chat, "Sorry #{sender}, bot can't complete that search: #{reason}")
    end
  end

  def handle_message(message, sender, chat) do
    Logger.debug("Message in #{chat} from #{sender}: #{message}")
  end

  defp search_hack("hack waiting " <> rest), do: Search.for(rest, resource: :hack, waiting: true)
  defp search_hack("hack " <> rest), do: Search.for(rest, resource: :hack)
end
