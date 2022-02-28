defmodule SMWCBot do
  use TMI.Handler

  alias SMWCBot.Search

  require Logger

  @impl true
  def handle_message("!" <> command, sender, chat) do
    case search_hack(command) do
      {text, href} ->
        TMI.message(chat, "Here #{sender}: #{text} @ #{href}")

      nil ->
        TMI.message(chat, "Sorry #{sender}, no results")
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
