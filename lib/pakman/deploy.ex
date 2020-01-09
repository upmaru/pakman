defmodule Pakman.Deploy do
  alias Pakman.Instellar

  require Logger

  defmodule Failure do
    defexception [:message]
  end

  def perform(options) do
    package_path = Keyword.fetch!(options, :package_path)

    with {:ok, token} <- Instellar.authenticate(),
         {:ok, response} <- Instellar.create_deployment(token, package_path) do
      Logger.info("[Pakman.Deploy] Deployment successfully created...")
    else
      _ ->
        raise Failure, message: "[Pakman.Deploy] Deployment creation failed..."
    end
  end
end
