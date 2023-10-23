defmodule Pakman.CLITest do
  use ExUnit.Case

  test "raise if invalid command" do
    assert_raise RuntimeError, ~s(Unknown command: "run"), fn ->
      Pakman.CLI.main(["run"])
    end
  end
end
