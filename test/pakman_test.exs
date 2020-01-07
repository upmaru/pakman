defmodule PakmanTest do
  use ExUnit.Case
  doctest Pakman

  test "greets the world" do
    assert Pakman.hello() == :world
  end
end
