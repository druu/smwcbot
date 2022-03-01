defmodule SMWCBot.Parser do
  @moduledoc """
  Parser behaviour.
  """

  @type parse_result ::
          {:ok, text :: String.t(), href :: String.t()}
          | {:ok, :multi, href :: String.t()}
          | {:ok, nil}
          | {:error, String.t()}

  @callback parse_body(String.t(), String.t(), atom(), boolean()) :: parse_result()
end
