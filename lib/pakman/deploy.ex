defmodule Pakman.Deploy do
  alias Pakman.Instellar

  require Logger

  defmodule Failure do
    defexception [:message]
  end

  def perform(options) do
    archive = Keyword.fetch!(options, :archive)

    with {:ok, token} <- Instellar.authenticate(),
         {:ok, message, _response} <-
           Instellar.create_deployment(token, archive) do
      print_success_message(message)
    else
      _ ->
        raise Failure, message: "[Pakman.Deploy] Deployment creation failed..."
    end
  end

  defp print_success_message(:created),
    do: Logger.info("[Pakman.Deploy] Deployment successfully created...")

  defp print_success_message(:already_exists),
    do: Logger.info("[Pakman.Deploy] Deployment already exists...")
end
