defmodule Pakman.Instellar do
  use Tesla

  alias Tesla.Multipart

  def authenticate do
    auth_token = System.get_env("INSTELLAR_AUTH_TOKEN")

    client()
    |> post("/publish/automation/callback", %{auth_token: auth_token})
    |> case do
      {:ok, %{status: 201, body: body}} -> {:ok, body["data"]["token"]}
      {:ok, %{status: 404}} -> {:error, :not_found}
    end
  end

  def create_deployment(token, archive_path) do
    package_token = System.get_env("INSTELLAR_PACKAGE_TOKEN")

    headers = [
      {"authorization", "Bearer #{token}"},
      {"x-instellar-package-token", package_token}
    ]

    ref = System.get_env("WORKFLOW_REF") || System.get_env("GITHUB_REF")
    sha = System.get_env("WORKFLOW_SHA") || System.get_env("GITHUB_SHA")

    multipart =
      Multipart.new()
      |> Multipart.add_content_type_param("application/x-www-form-urlencoded")
      |> Multipart.add_file(archive_path, name: "deployment[archive]")
      |> Multipart.add_field("deployment[ref]", ref)
      |> Multipart.add_field("deployment[hash]", sha)

    client()
    |> post("/publish/deployments", multipart, headers: headers)
    |> case do
      {:ok, %{status: 201, body: body}} ->
        {:ok, :created, body["data"]}

      {:ok, %{status: 200, body: body}} ->
        {:ok, :already_exists, body["data"]}

      _ ->
        {:error, :deployment_creation_failed}
    end
  end

  defp client do
    endpoint = System.get_env("INSTELLAR_ENDPOINT", "https://web.instellar.app")

    middleware = [
      {Tesla.Middleware.BaseUrl, endpoint},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger
    ]

    Tesla.client(middleware)
  end
end
