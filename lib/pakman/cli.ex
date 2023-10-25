defmodule Pakman.CLI do
  @switches %{
    bootstrap: [
      switches: [
        config: :string
      ]
    ],
    push: [
      switches: [
        concurrency: :integer,
        config: :string,
        archive: :string
      ]
    ]
  }

  @commands %{
    "bootstrap" => :bootstrap,
    "push" => :push
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
