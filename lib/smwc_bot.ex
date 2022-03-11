defmodule SMWCBot do
  @moduledoc """
  Main bot handler.
  """
  use TMI

  alias SMWC.Resources
  alias SMWCBot.MessageServer

  require Logger

  @compile_config Application.compile_env(:smwc, SMWCBot)
  @command_prefix Keyword.get(@compile_config, :command_prefix, "!")

  @doc """
  Adds a message to the outbound message queue.
  """
  @spec send_message(String.t(), String.t()) :: :ok
  def send_message(chat, message) do
    MessageServer.add_message(chat, message)
  end

  ## Callbacks

  @impl TMI.Handler
  def handle_message(@command_prefix <> command, sender, chat, _tags) do
    case execute(command) do
      {:ok, :multi, href} ->
        say(chat, "#{sender}, I found multiple results @ #{href}")

      {:ok, text, href} ->
        say(chat, "#{sender}, #{text} @ #{href}")

      {:ok, nil} ->
        say(chat, "Sorry #{sender}, no results")

      {:error, reason} ->
        say(chat, "Sorry #{sender}, bot can't complete that search: #{reason}")
    end
  end

  def handle_message(message, sender, chat, _tags) do
    Logger.debug("[SMWCBot] Message in #{chat} from #{sender}: #{message}")
  end

  defp execute("asm " <> rest), do: search(Resources.UberASM, rest)
  defp execute("blocks " <> rest), do: search(Resources.Blocks, rest)
  defp execute("graphics " <> rest), do: search(Resources.Graphics, rest)
  defp execute("hack " <> rest), do: search(Resources.Hack, rest)
  defp execute("music " <> rest), do: search(Resources.Music, rest)
  defp execute("patches " <> rest), do: search(Resources.Patches, rest)
  defp execute("sprites " <> rest), do: search(Resources.Sprites, rest)
  defp execute("uberasm " <> rest), do: search(Resources.UberASM, rest)

  defp search(resource, command) do
    case parse_command(command) do
      {opts, args, []} ->
        args
        |> Enum.join(" ")
        |> SMWC.search([{:resource, resource} | opts])

      {_opts, _args, invalid} ->
        {:error, "unrecognized options: #{inspect(invalid)}"}
    end
  end

  defp parse_command(command) do
    command
    |> String.split(" ", trim: true)
    |> OptionParser.parse(
      strict: [
        author: :string,
        first: :boolean,
        order: :string,
        waiting: :boolean
      ],
      aliases: [
        a: :author,
        f: :first,
        o: :order,
        w: :waiting
      ]
    )
  end
end
