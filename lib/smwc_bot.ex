defmodule SMWCBot do
  use TMI.Handler

  alias SMWCBot.Search

  require Logger

  @impl true
  def handle_message("!" <> command, sender, chat) do
    case search_hack(command) do
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

  def search_hack(command) do
    command
    |> build_query()
    |> Search.for()
  end

  defp build_query("hack waiting " <> rest), do: {rest, "waiting"}
  defp build_query("hack " <> rest), do: {rest, ""}
end
