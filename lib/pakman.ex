defmodule Pakman do
  @moduledoc """
  Documentation for Pakman.
  """

  defdelegate bootstrap(options),
    to: Pakman.Bootstrap,
    as: :perform

  defdelegate push(options),
    to: Pakman.Push,
    as: :perform

  defdelegate deploy(options),
    to: Pakman.Deploy,
    as: :perform
end
