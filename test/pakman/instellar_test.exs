defmodule Pakman.InstellarTest do
  use ExUnit.Case

  alias Pakman.Instellar

  setup do
    bypass = Bypass.open()

    System.put_env("INSTELLAR_PACKAGE_TOKEN", "somepackage")
    System.put_env("INSTELLAR_ENDPOINT", "http://localhost:#{bypass.port}")

    with_kits_and_sizes = YamlElixir.read_from_file!("test/fixtures/rails.yml")
    with_kits = YamlElixir.read_from_file!("test/fixtures/laravel.yml")

    {:ok,
     bypass: bypass,
     config_with_kits: with_kits,
     config_with_kits_and_sizes: with_kits_and_sizes}
  end

  describe "create_configuration" do
    test "calls instellar to create configuration", %{
      bypass: bypass,
      config_with_kits_and_sizes: config
    } do
      Bypass.expect_once(
        bypass,
        "POST",
        "/publish/deployments/1/configurations",
        fn conn ->
          {:ok, body, _} = Plug.Conn.read_body(conn)

          assert %{"configuration" => %{"payload" => payload}} =
                   Jason.decode!(body)

          assert %{"kits" => kits, "sizes" => sizes} = payload

          assert Enum.count(sizes) == 1

          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(201, Jason.encode!(%{data: %{id: 1}}))
        end
      )

      {:ok, :created, _} = Instellar.create_configuration("token", 1, config)
    end

    test "configuration without size", %{
      bypass: bypass,
      config_with_kits: config
    } do
      Bypass.expect_once(
        bypass,
        "POST",
        "/publish/deployments/1/configurations",
        fn conn ->
          {:ok, body, _} = Plug.Conn.read_body(conn)

          assert %{"configuration" => %{"payload" => payload}} =
                   Jason.decode!(body)

          assert %{"kits" => kits} = payload

          assert is_nil(payload["sizes"])

          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(201, Jason.encode!(%{data: %{id: 1}}))
        end
      )

      {:ok, :created, _} = Instellar.create_configuration("token", 1, config)
    end

    test "does not call instellar" do
      {:ok, :no_configuration, %{}} =
        Instellar.create_configuration("token", 1, %{})
    end
  end
end
