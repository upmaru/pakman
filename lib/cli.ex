defmodule Apkify.CLI do
  alias Apkify.Bootstrap

  def main(args \\ []) do
    args
    |> parse_args()
    |> Bootstrap.perform()
  end

  defp parse_args(args) do
    {opts, _word, _} =
      args
      |> OptionParser.parse(switches: [repository: :string, version: :string, build: :string])

    opts
  end
end
