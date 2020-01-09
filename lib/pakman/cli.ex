defmodule Pakman.CLI do
  @switches [
    switches: [
      command: :string,
      options: :string
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
    {[command: command, options: options], _, _} = OptionParser.parse(args, @switches)
    command = String.to_atom(command)

    apply(Pakman, command, [parse_args(command, options)])
  end

  defp parse_args(command, args) do
    switches = Keyword.fetch!(@sub_switches, command)

    {opts, _word, _} =
      args
      |> OptionParser.parse(switches)

    opts
  end
end
