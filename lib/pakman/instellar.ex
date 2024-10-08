defmodule Pakman.Instellar do
  use Tesla

  require Logger

  def authenticate do
    auth_token = System.get_env("INSTELLAR_AUTH_TOKEN")

    client()
    |> post("/publish/automation/callback", %{auth_token: auth_token})
    |> case do
      {:ok, %{status: 201, body: body}} -> {:ok, body["data"]["token"]}
      {:ok, %{status: 404}} -> {:error, :not_found}
    end
  end

  def get_storage(token) do
    package_token = System.get_env("INSTELLAR_PACKAGE_TOKEN")

    headers = [
      {"authorization", "Bearer #{token}"},
      {"x-instellar-package-token", package_token}
    ]

    client()
    |> get("/publish/storage", headers: headers)
    |> case do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body["data"]}

      _ ->
        {:error, :get_storage_failed}
    end
  end

  def get_deployment(token, hash) do
    package_token = System.get_env("INSTELLAR_PACKAGE_TOKEN")

    headers = [
      {"authorization", "Bearer #{token}"},
      {"x-instellar-package-token", package_token}
    ]

    client()
    |> get("/publish/deployments/#{hash}", headers: headers)
    |> case do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body["data"]}

      {:ok, %{status: 404}} ->
        {:ok, :not_found}
    end
  end

  @spec create_deployment(binary, binary, map) ::
          {:ok, atom, map} | {:error, atom}
  def create_deployment(token, archive_path, config_params) do
    package_token = System.get_env("INSTELLAR_PACKAGE_TOKEN")

    headers = [
      {"authorization", "Bearer #{token}"},
      {"x-instellar-package-token", package_token}
    ]

    ref = System.get_env("WORKFLOW_REF") || System.get_env("GITHUB_REF")
    sha = System.get_env("WORKFLOW_SHA") || System.get_env("GITHUB_SHA")

    deployment_params = %{
      ref: ref,
      hash: sha,
      archive_path: archive_path
    }

    deployment_params = add_stack(deployment_params, config_params["stack"])

    client()
    |> post("/publish/deployments", %{deployment: deployment_params},
      headers: headers
    )
    |> case do
      {:ok, %{status: 201, body: body}} ->
        {:ok, :created, body["data"]}

      {:ok, %{status: 200, body: body}} ->
        {:ok, :already_exists, body["data"]}

      error ->
        Logger.error("[Pakman.Instellar] #{inspect(error)}")

        {:error, :deployment_creation_failed}
    end
  end

  def create_configuration(
        token,
        deployment_id,
        %{"kits" => kits} = configuration
      )
      when is_list(kits) do
    package_token = System.get_env("INSTELLAR_PACKAGE_TOKEN")

    headers = [
      {"authorization", "Bearer #{token}"},
      {"x-instellar-package-token", package_token}
    ]

    sizes = Map.get(configuration, "sizes")
    plans = Map.get(configuration, "plans")
    page = Map.get(configuration, "page")

    configuration_params = %{
      payload: %{
        kits: kits
      }
    }

    configuration_params =
      if sizes do
        payload = configuration_params.payload
        payload = Map.put(payload, :sizes, sizes)

        Map.put(configuration_params, :payload, payload)
      else
        configuration_params
      end

    configuration_params =
      if plans do
        payload = configuration_params.payload
        payload = Map.put(payload, :plans, plans)

        Map.put(configuration_params, :payload, payload)
      else
        configuration_params
      end

    configuration_params =
      if page do
        payload = configuration_params.payload
        payload = Map.put(payload, :page, page)

        Map.put(configuration_params, :payload, payload)
      else
        configuration_params
      end

    client()
    |> post(
      "/publish/deployments/#{deployment_id}/configurations",
      %{configuration: configuration_params},
      headers: headers
    )
    |> case do
      {:ok, %{status: 201, body: body}} ->
        {:ok, :created, body["data"]}

      {:ok, %{status: 200, body: body}} ->
        {:ok, :already_exists, body["data"]}

      {:ok, %{status: 422, body: body}} ->
        {:error, body}

      _ ->
        {:error, :configuration_creation_failed}
    end
  end

  def create_configuration(_token, _deployment_id, _configuration) do
    {:ok, :no_configuration, %{}}
  end

  defp add_stack(params, nil), do: params

  defp add_stack(params, stack)
       when is_binary(stack),
       do: Map.put(params, :stack, stack)

  defp client do
    endpoint = System.get_env("INSTELLAR_ENDPOINT", "https://opsmaru.com")

    middleware =
      if Application.get_env(:pakman, :env) == :test do
        [
          {Tesla.Middleware.BaseUrl, endpoint},
          Tesla.Middleware.JSON,
          {Tesla.Middleware.Logger,
           debug: false, log_level: &custom_log_level/1}
        ]
      else
        [
          {Tesla.Middleware.BaseUrl, endpoint},
          Tesla.Middleware.JSON,
          {Tesla.Middleware.Logger,
           debug: false, log_level: &custom_log_level/1}
        ]
      end

    Tesla.client(middleware)
  end

  defp custom_log_level(env) do
    case env.status do
      404 -> :info
      _ -> :default
    end
  end
end
