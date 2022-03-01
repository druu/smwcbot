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
    case execute(command) do
      {:ok, :multi, href} ->
        TMI.message(chat, "#{sender}, I found multiple results @ #{href}")

      {:ok, text, href} ->
        TMI.message(chat, "#{sender}, #{text} @ #{href}")

      {:ok, nil} ->
        TMI.message(chat, "Sorry #{sender}, no results")

      {:error, reason} ->
        TMI.message(chat, "Sorry #{sender}, bot can't complete that search: #{reason}")
    end
  end

  def handle_message(message, sender, chat) do
    Logger.debug("Message in #{chat} from #{sender}: #{message}")
  end

  defp execute("blocks " <> rest), do: search(:blocks, rest)
  defp execute("graphics " <> rest), do: search(:graphics, rest)
  defp execute("hack " <> rest), do: search(:hack, rest)
  defp execute("music " <> rest), do: search(:music, rest)

  defp search(resource, command) do
    case parse_command(command) do
      {opts, args, []} ->
        args
        |> Enum.join(" ")
        |> Search.for([{:resource, resource} | opts])

      {_opts, _args, invalid} ->
        {:error, "unrecognized options: #{inspect(invalid)}"}
    end
  end

  defp parse_command(command) do
    command
    |> String.split(" ", trim: true)
    |> OptionParser.parse(
      strict: [
        first: :boolean,
        order: :string,
        waiting: :boolean
      ],
      aliases: [
        f: :first,
        o: :order,
        w: :waiting
      ]
    )
  end
end
