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
    test "caddy config" do
      System.put_env("HOME", "tmp/caddy")
      System.put_env("GITHUB_WORKSPACE", "tmp/caddy")
      System.put_env("GITHUB_REPOSITORY", "upmaru/uplink-caddy")

      Pakman.SystemMock
      |> expect(:cmd, 2, fn _binary, _options ->
        :ok
      end)

      assert :ok ==
               Pakman.Bootstrap.perform(config: "test/fixtures/caddy.yml")
    end

    test "rails config" do
      System.put_env("HOME", "tmp/rails")
      System.put_env("GITHUB_WORKSPACE", "tmp/rails")
      System.put_env("GITHUB_REPOSITORY", "upmaru/rails")

      Pakman.SystemMock
      |> expect(:cmd, 2, fn _binary, _options ->
        :ok
      end)

      assert :ok ==
               Pakman.Bootstrap.perform(config: "test/fixtures/rails.yml")

      apkbuild = File.read!("tmp/rails/.apk/upmaru/rails/APKBUILD")

      assert apkbuild =~ "!tracedeps"
    end

    test "elixir config" do
      System.put_env("HOME", "tmp/elixir")
      System.put_env("GITHUB_WORKSPACE", "tmp/elixir")
      System.put_env("GITHUB_REPOSITORY", "upmaru/elixir")

      Pakman.SystemMock
      |> expect(:cmd, 2, fn _binary, _options ->
        :ok
      end)

      assert :ok ==
               Pakman.Bootstrap.perform(config: "test/fixtures/elixir.yml")

      apkbuild = File.read!("tmp/elixir/.apk/upmaru/elixir/APKBUILD")

      refute apkbuild =~ "!tracedeps"
    end

    test "next config" do
      System.put_env("HOME", "tmp/next")
      System.put_env("GITHUB_WORKSPACE", "tmp/next")

      Pakman.SystemMock
      |> expect(:cmd, 2, fn _binary, _options ->
        :ok
      end)

      assert :ok ==
               Pakman.Bootstrap.perform(config: "test/fixtures/next.yml")
    end
  end
end
