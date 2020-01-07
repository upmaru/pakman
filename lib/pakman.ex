defmodule Pakman do
  @moduledoc """
  Documentation for Pakman.
  """
  defdelegate bootstrap(options), to: Pakman.Bootstrap, as: :perform
  defdelegate setup, to: Pakman.Setup, as: :perform
end
