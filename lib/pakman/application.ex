defmodule Pakman.Application do
  use Application

  @cacerts CAStore.file_path()
           |> File.read!()
           |> :public_key.pem_decode()
           |> Enum.map(fn {_, cert, _} -> cert end)

  def start(_, _) do
    children = [
      {Finch, finch_options(Application.get_env(:pakman, :env))},
      {Task.Supervisor, name: Pakman.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Instellar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp finch_options(:test), do: [name: Pakman.Finch]

  defp finch_options(_) do
    [
      name: Pakman.Finch,
      pools: %{
        default: [
          conn_opts: [
            transport_opts: [
              verify: :verify_peer,
              cacerts: @cacerts
            ]
          ]
        ]
      }
    ]
  end
end
