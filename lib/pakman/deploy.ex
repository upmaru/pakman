defmodule Pakman.Deploy do
  alias Pakman.Instellar

  require Logger

  defmodule Failure do
    defexception [:message]
  end

  def perform(options) do
    archive = Keyword.fetch!(options, :archive)

    with {:ok, token} <- Instellar.authenticate(),
         {:ok, _response} <- Instellar.create_deployment(token, archive) do
      Logger.info("[Pakman.Deploy] Deployment successfully created...")
    else
      _ ->
        raise Failure, message: "[Pakman.Deploy] Deployment creation failed..."
    end
  end
end
