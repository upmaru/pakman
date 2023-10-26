defmodule Pakman.Push do
  @moduledoc """
  Push built packages to storage
  """

  alias Pakman.Instellar
  alias Pakman.FileExt

  alias ExAws.S3

  require Logger

  defmodule Error do
    defexception message: "Push failed"
  end

  def perform(options \\ [concurrency: 2]) do
    archive = Keyword.get(options, :archive, "packages.zip")
    config_file = Keyword.get(options, :config, "instellar.yml")
    workspace = System.get_env("GITHUB_WORKSPACE")
    hash = System.get_env("WORKFLOW_SHA") || System.get_env("GITHUB_SHA")

    config =
      workspace
      |> Path.join(config_file)
      |> YamlElixir.read_from_file!()

    with {:ok, token} <- Instellar.authenticate(),
         {:ok, :not_found} <- Instellar.get_deployment(token, hash),
         {:ok, %{"attributes" => storage}} <- Instellar.get_storage(token),
         {:ok, %{archive: archive_path}} <-
           push_files(storage, archive, options),
         {:ok, deployment_message, response} <-
           Instellar.create_deployment(token, archive_path, config),
         {:ok, configuration_message, _response} <-
           Instellar.create_configuration(
             token,
             response["attributes"]["id"],
             config
           ) do
      print_deployment_message(deployment_message)
      print_configuration_message(configuration_message)

      {:ok, :pushed}
    else
      {:ok, %{"attributes" => %{"id" => _}}} ->
        Logger.info("[Pakman.Push] Deployment already exists...")

        {:ok, :already_exists}

      {:error, body} ->
        raise Error, message: "[Pakman.Push] #{inspect(body)}"

      _ ->
        raise Error, message: "[Pakman.Push] Deployment creation failed..."
    end
  end

  def push_files(storage, archive, options) do
    home = System.get_env("HOME")
    sha = System.get_env("WORKFLOW_SHA") || System.get_env("GITHUB_SHA")

    packages_dir = Path.join(home, "packages")
    archive_path = Path.join(home, archive)

    files =
      FileExt.ls_r(packages_dir)
      |> Enum.map(fn path -> {:deployments, path, sha} end)
      |> Enum.concat([{:archives, archive_path, Uniq.UUID.uuid4()}])

    storage = %{
      config:
        ExAws.Config.new(:s3,
          access_key_id: storage["credential"]["access_key_id"],
          secret_access_key: storage["credential"]["secret_access_key"],
          host: storage["host"],
          port: storage["port"],
          scheme: storage["scheme"],
          region: storage["region"]
        ),
      bucket: storage["bucket"]
    }

    stream =
      Task.Supervisor.async_stream(
        Pakman.TaskSupervisor,
        files,
        __MODULE__,
        :push,
        [storage],
        max_concurrency: Keyword.get(options, :concurrency, 2),
        timeout: 60_000
      )

    uploads = Enum.to_list(stream)

    successful_uploads =
      Enum.filter(uploads, fn {result, _} -> result == :ok end)

    if Enum.count(successful_uploads) == Enum.count(files) do
      Logger.info("[Pakman.Push] completed - #{sha}")

      {:ok, upload} =
        Enum.find(successful_uploads, fn {:ok, result} ->
          result.type == :archive
        end)

      {:ok, %{archive: upload.path}}
    else
      comment = "partially failed"
      message = "[Pakman.Push] #{comment} - #{sha}"
      Logger.error(message)
      raise Error, message: message
    end
  end

  def push({:archives, path, id}, storage) do
    storage_path = Path.join(["archives", id, Path.basename(path)])

    path
    |> S3.Upload.stream_file()
    |> S3.upload(storage.bucket, storage_path)
    |> ExAws.request(Keyword.new(storage.config))
    |> case do
      {:ok, _result} ->
        Logger.info("[Pakman.Push] pushed - #{storage_path}")

        %{type: :archive, path: storage_path}

      error ->
        error
    end
  end

  def push({:deployments, path, sha}, storage) do
    %{organization: organization, name: name} = Pakman.Environment.repository()

    file_with_arch_name =
      path
      |> Path.split()
      |> Enum.take(-2)
      |> Path.join()

    storage_path =
      Path.join([
        "deployments",
        organization,
        name,
        sha,
        file_with_arch_name
      ])

    path
    |> S3.Upload.stream_file()
    |> S3.upload(storage.bucket, storage_path)
    |> ExAws.request(Keyword.new(storage.config))
    |> case do
      {:ok, _result} ->
        Logger.info("[Pakman.Push] pushed - #{storage_path}")

        %{type: :deployment, path: storage_path}

      error ->
        error
    end
  end

  defp print_deployment_message(:created),
    do: Logger.info("[Pakman.Deploy] Deployment successfully created...")

  defp print_deployment_message(:already_exists),
    do: Logger.info("[Pakman.Deploy] Deployment already exists...")

  defp print_configuration_message(:created),
    do: Logger.info("[Pakman.Deploy] Configuration successfully created...")

  defp print_configuration_message(:already_exists),
    do: Logger.info("[Pakman.Deploy] Configuration already exists...")

  defp print_configuration_message(:no_configuration),
    do: Logger.info("[Pakman.Deploy] Configuration not found...")
end
