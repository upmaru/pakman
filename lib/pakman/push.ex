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
    Logger.info("[Pakman.Push] pushing...")

    with {:ok, token} <- Instellar.authenticate(),
         {:ok, %{"attributes" => storage}} <- Instellar.get_storage(token) do
      home = System.get_env("HOME")
      sha = System.get_env("WORKFLOW_SHA") || System.get_env("GITHUB_SHA")

      packages_path = Path.join(home, "packages")

      files = FileExt.ls_r(packages_path)

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
          Pakman.TaskSupservisor,
          files,
          __MODULE__,
          :push,
          [storage, sha],
          max_concurrency: Keyword.get(options, :concurrency, 2)
        )

      uploads = Enum.to_list(stream)

      successful_uploads =
        Enum.filter(uploads, fn {result, _} -> result == :ok end)

      if Enum.count(successful_uploads) == Enum.count(files) do
        Logger.info("[Pakman.Push] completed - #{sha}")

        {:ok, uploads}
      else
        comment = "partially failed"
        message = "[Pakman.Push] #{comment} - #{sha}"
        Logger.error(message)
        raise Error, message: message
      end
    end
  end

  def push(path, storage, sha) do
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
      {:ok, result} ->
        Logger.info("[Pakman.Push] pushed - #{storage_path}")

        {:ok, result}

      error ->
        error
    end
  end
end
