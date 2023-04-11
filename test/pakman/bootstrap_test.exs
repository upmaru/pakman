defmodule Pakman.BootstrapTest do
  use ExUnit.Case

  import Mox

  setup do
    System.put_env("HOME", "tmp")
    System.put_env("ABUILD_PRIVATE_KEY", "something")
    System.put_env("ABUILD_PUBLIC_KEY", "something")
    System.put_env("GITHUB_REPOSITORY", "upmaru/uplink")
    System.put_env("GITHUB_WORKSPACE", "tmp")
    System.put_env("GITHUB_RUN_NUMBER", "1")

    :ok
  end

  describe "perform" do
    test "can bootstrap" do
      Pakman.SystemMock
      |> expect(:cmd, fn _binary, _options ->
        :ok
      end)

      assert :ok ==
               Pakman.Bootstrap.perform(config_file: "test/fixtures/rails.yml")
    end
  end
end
