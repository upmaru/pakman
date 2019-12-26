defmodule Apkify do
  @moduledoc """
  Documentation for Apkify.
  """
  defdelegate bootstrap(options), to: Apkify.Bootstrap, as: :perform
  defdelegate setup, to: Apkify.Setup, as: :perform
end
