defmodule ApkifyTest do
  use ExUnit.Case
  doctest Apkify

  test "greets the world" do
    assert Apkify.hello() == :world
  end
end
