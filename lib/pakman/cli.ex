defmodule Pakman.CLI do
  @switches [
    switches: [
      command: :string
    ]
  ]

  @sub_switches [
    bootstrap: [
      switches: [
        version: :string,
        build: :string,
        depends: :string,
        makedepends: :string
      ]
    ],
    create_deployment: [
      switches: [
        package_path: :string
      ]
    ],
    prepare_launch_deployment: [
      switches: []
    ]
  ]

  def main(args \\ []) do
    {[command: command], [], []} = OptionParser.parse(args, @switches)

    apply(Pakman, command, [parse_args(String.to_atom(command), args)])
  end

  defp parse_args(command, args) do
    switches = Keyword.fetch!(@sub_switches, command)

    {opts, _word, _} =
      args
      |> OptionParser.parse(switches)

    opts
  end
end
