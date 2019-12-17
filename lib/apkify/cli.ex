defmodule Apkify.CLI do
  alias Apkify.Bootstrap

  def main(args \\ []) do
    args
    |> parse_args
    |> Bootstrap.perform()
    |> File.cd!()
    
    System.cmd(~s(abuild), ~w(snapshot))
    System.cmd(~s(abuild), ~w(-r))
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
