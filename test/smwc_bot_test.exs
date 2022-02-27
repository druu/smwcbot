defmodule SMWCBotTest do
  use ExUnit.Case
  doctest SMWCBot

  test "greets the world" do
    assert SMWCBot.hello() == :world
  end
end
