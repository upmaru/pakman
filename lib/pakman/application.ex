defmodule Pakman.Application do
  use Application

  def start(_, _) do
    children = [
      {Finch,
       name: PakmanFinch,
       pools: %{
         default: [
           conn_opts: [
             transport_opts: [
               cacertfile: "priv/cacerts.pem"
             ]
           ]
         ]
       }}
    ]

    opts = [strategy: :one_for_one, name: Instellar.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
