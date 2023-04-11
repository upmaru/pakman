defmodule Pakman do
  @moduledoc """
  Documentation for Pakman.
  """
  defdelegate bootstrap(options),
    to: Pakman.Bootstrap,
    as: :perform

  defdelegate create_deployment(options),
    to: Pakman.Deploy,
    as: :perform

  defdelegate prepare_launch_deployment(options),
    to: Pakman.Deploy.Prepare,
    as: :perform

  defdelegate setup, to: Pakman.Setup, as: :perform
end
