defmodule Pakman.PushTest do
  use ExUnit.Case

  alias Pakman.Push

  setup do
    bypass = Bypass.open()

    storage = %{
      "host" => "localhost",
      "port" => 9000,
      "scheme" => "http://",
      "region" => "auto",
      "bucket" => "test",
      "credential" => %{
        "access_key_id" => "minioadmin",
        "secret_access_key" => "minioadmin"
      }
    }

    ex_aws_config =
      ExAws.Config.new(:s3,
        access_key_id: storage["credential"]["access_key_id"],
        secret_access_key: storage["credential"]["secret_access_key"],
        host: storage["host"],
        port: storage["port"],
        scheme: storage["scheme"],
        region: storage["region"]
      )

    System.put_env("HOME", "test/fixtures")
    System.put_env("GITHUB_WORKSPACE", "")
    System.put_env("INSTELLAR_ENDPOINT", "http://localhost:#{bypass.port}")
    System.put_env("INSTELLAR_PACKAGE_TOKEN", "something")
    System.put_env("WORKFLOW_SHA", "somesha")
    System.put_env("GITHUB_REPOSITORY", "upmaru-stage/locomo")

    ExAws.S3.put_bucket(storage["bucket"], storage["region"])
    |> ExAws.request(Keyword.new(ex_aws_config))

    {:ok, bypass: bypass}
  end

  describe "push assets and create deployment" do
    test "successfully push and create deployment", %{bypass: bypass} do
      Bypass.expect(bypass, "POST", "/publish/automation/callback", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(201, Jason.encode!(%{data: %{token: "something"}}))
      end)

      Bypass.expect(bypass, "GET", "/publish/storage", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(
          200,
          Jason.encode!(%{
            data: %{
              attributes: %{
                "host" => "localhost",
                "port" => 9000,
                "scheme" => "http://",
                "region" => "auto",
                "bucket" => "test",
                "credential" => %{
                  "access_key_id" => "minioadmin",
                  "secret_access_key" => "minioadmin"
                }
              }
            }
          })
        )
      end)

      Bypass.expect(bypass, "POST", "/publish/deployments", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(
          201,
          Jason.encode!(%{
            data: %{
              attributes: %{
                "id" => 1,
                "archive_path" => "archives/some-uuid/packages.zip"
              }
            }
          })
        )
      end)

      Bypass.expect_once(
        bypass,
        "POST",
        "/publish/deployments/1/configurations",
        fn conn ->
          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(201, Jason.encode!(%{data: %{id: 1}}))
        end
      )

      assert {:ok, :pushed} = Push.perform(config: "test/fixtures/rails.yml")
    end
  end
end
