defmodule Apkify.CLI do
  alias Apkify.Bootstrap

  def main(args \\ []) do
    options = parse_args(args)

    Bootstrap.perform(options)
  end

  defp parse_args(args) do
    {opts, _word, _} =
      args
      |> OptionParser.parse(
        switches: [
          repository: :string,
          version: :string,
          build: :string,
          depends: :string,
          makedepends: :string
        ]
      )

    opts
  end
end
