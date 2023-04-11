defmodule Pakman.BootstrapTest do
  use ExUnit.Case

  import Mox

  setup do
    System.put_env("ABUILD_PRIVATE_KEY", "something")
    System.put_env("ABUILD_PUBLIC_KEY", "something")
    System.put_env("GITHUB_REPOSITORY", "upmaru/uplink")
    System.put_env("GITHUB_RUN_NUMBER", "1")

    :ok
  end

  describe "perform" do
    test "rails config" do
      System.put_env("HOME", "tmp/rails")
      System.put_env("GITHUB_WORKSPACE", "tmp/rails")

      Pakman.SystemMock
      |> expect(:cmd, fn _binary, _options ->
        :ok
      end)

      assert :ok ==
               Pakman.Bootstrap.perform(config_file: "test/fixtures/rails.yml")

      apkbuild = File.read!("tmp/rails/.apk/upmaru/uplink/APKBUILD")

      assert apkbuild =~ "!tracedeps"
    end

    test "elixir config" do
      System.put_env("HOME", "tmp/elixir")
      System.put_env("GITHUB_WORKSPACE", "tmp/elixir")

      Pakman.SystemMock
      |> expect(:cmd, fn _binary, _options ->
        :ok
      end)

      assert :ok ==
               Pakman.Bootstrap.perform(config_file: "test/fixtures/elixir.yml")

      apkbuild = File.read!("tmp/elixir/.apk/upmaru/uplink/APKBUILD")

      refute apkbuild =~ "!tracedeps"
    end
  end
end
