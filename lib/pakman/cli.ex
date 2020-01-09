defmodule Pakman.CLI do
  @switches [
    switches: [
      command: :string,
      version: :string,
      build: :string,
      depends: :string,
      makedepends: :string,
      package_path: :string
    ]
  ]

  def main(args \\ []) do
    {[{:command, command} | options], _, _} =
      OptionParser.parse(args, @switches)

    command = String.to_atom(command)

    apply(Pakman, command, [options])
  end
end
