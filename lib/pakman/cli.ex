defmodule Pakman.CLI do
  @switches [
    switches: [
      command: :string,
      version: :string,
      build: :string,
      depends: :string,
      makedepends: :string,
      archive: :string
    ]
  ]

  def main(args \\ []) do
    {[{:command, command} | options], _, _} =
      OptionParser.parse(args, @switches)

    command = String.to_atom(command)
    
    System.cmd("sudo", ["chown", "-R", "root:root", System.get_env("GITHUB_WORKSPACE")])

    apply(Pakman, command, [options])
  end
end
