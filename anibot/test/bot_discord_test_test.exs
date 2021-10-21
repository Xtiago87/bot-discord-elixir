defmodule BotDiscordTestTest do
  use ExUnit.Case
  doctest BotDiscordTest

  test "greets the world" do
    assert BotDiscordTest.hello() == :world
  end
end
