defmodule Pakman.CLI do
  @switches [
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
    command =
      args
      |> List.first()
      |> String.to_atom()

    apply(Pakman, command, [parse_args(command, args)])
  end

  defp parse_args(command, args) do
    switches = Keyword.fetch!(@switches, command)

    {opts, _word, _} =
      args
      |> OptionParser.parse(switches)

    opts
  end
end
