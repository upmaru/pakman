defmodule Pakman.Deploy do
  alias Pakman.Instellar

  require Logger

  defmodule Failure do
    defexception [:message]
  end

  def perform(options) do
    archive = Keyword.fetch!(options, :archive)

    with {:ok, token} <- Instellar.authenticate(),
         {:ok, deployment_message, response} <-
           Instellar.create_deployment(token, archive),
         {:ok, configuration_message, _response} <-
           Instellar.create_configuration(token, response["attributes"]["id"]) do
      print_deployment_message(deployment_message)
      print_configuration_message(configuration_message)
    else
      _ ->
        raise Failure, message: "[Pakman.Deploy] Deployment creation failed..."
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
end
