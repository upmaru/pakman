defmodule Pakman.Push do
  @moduledoc """
  Push built packages to storage
  """

  alias Pakman.Instellar
  alias Pakman.FileExt

  defmodule Error do
    defexception message: "Push failed"
  end

  def perform(options) do
    with {:ok, token} <- Instellar.authenticate(),
         {:ok, %{"attributes" => storage}} <- Instellar.get_storage(token),
         {:ok, uploads} <- push_files(storage) do
      {:ok, uploads}
    end
  end

  defp push_files(storage, workspace, hash) do
    workspace = System.get_env("GITHUB_WORKSPACE")
    sha = System.get_env("WORKFLOW_SHA") || System.get_env("GITHUB_SHA")

    packages_path = Path.join(workspace, "packages")

    files = FileExt.ls_r(packages_path)

    storage = [
      config: ExAws.Config.new(:s3, 
        access_key_id: storage["credential"]["access_key_id"],
        secret_access_key: storage["credential"]["secret_access_key"],
        host: storage["host"],
        port: storage["port"],
        scheme: storage["scheme"],
        region: storage["region"]
      ),
      bucket: storage["bucket"]
    ]

    uploads = Enum.map(files, &push_file(&1, storage, sha))

    if Enum.count(uploads) == Enum.count(files) do
      Logger.info("[Pakman.Push] Push completed - #{identifier}")

      {:ok, uploads}
    else
      comment = "Upload partially failed"
      message = "[Pakman.Push] #{comment} - #{identifier}"
      Logger.error(message)
      raise Error, message: message
    end
  end

  defp push_file(path, config, identifier) do
    file_with_arch_name =
      path
      |> Path.split()
      |> Enum.take(-2)
      |> Path.join()

    storage_path = Path.join(identifier, file_with_arch_name)

    path
    |> S3.Upload.stream_file()
    |> S3.upload(bucket, storage_path)
    |> ExAws.request(config)
    |> IO.inspect()
  end
end