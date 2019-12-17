defmodule Apkify.CLI do
  alias Apkify.Bootstrap

  def main(args \\ []) do
    options = parse_args(args)

    Bootstrap.perform(options)

    apk_dir =
      [".apk", Keyword.get(options, :repository)]
      |> Enum.join("/")

    System.cmd(~s(cd), [Path.join(System.get_env(~s(GITHUB_WORKSPACE)), apk_dir)])

    System.cmd(~s(abuild), ["snapshot", "-F"])
    System.cmd(~s(abuild), ["-r", "-F"])
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
