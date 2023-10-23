defmodule Pakman.CLI do
  @switches %{
    create_deployment: [
      switches: [
        archive: :string,
        config: :string
      ]
    ]
  }

  @commands %{
    "bootstrap" => :bootstrap,
    "deploy" => :create_deployment
  }

  def main(args \\ []) do
    command = List.first(args)
    call = Map.get(@commands, command)

    if call do
      switches = Map.get(@switches, command, switches: [])

      {options, _, _} = OptionParser.parse(args, switches)

      apply(Pakman, call, [options])
    else
      raise "Unknown command: #{inspect(command)}"
    end
  end
end
