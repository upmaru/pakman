defmodule Pakman.Deploy do
  alias Pakman.Instellar

  def perform(options) do
    package_path = Keywor.fetch!(options, :package_path)

    with {:ok, token} <- Instellar.authenticate(),
         {:ok, response} <- Instellar.create_deployment(token, package_path) do
      Logger.info("[Pakman.Deploy] Deployment successfully created...")
    else
      _ -> raise "[Pakman.Deploy] Deployment creation failed..."
    end
  end
end
