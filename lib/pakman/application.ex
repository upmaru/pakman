defmodule Pakman.Application do
  use Application

  @cacerts CAStore.file_path()
           |> File.read!()
           |> :public_key.pem_decode()
           |> Enum.map(fn {_, cert, _} -> cert end)

  def start(_, _) do
    children =
      []
      |> append_finch()

    opts = [strategy: :one_for_one, name: Instellar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp append_finch(children) do
    if Application.get_env(:pakman, :env) == :test do
      children ++ [{Finch, name: Pakman.Finch}]
    else
      children ++
        [
          {Finch,
           name: Pakman.Finch,
           pools: %{
             default: [
               conn_opts: [
                 transport_opts: [
                   cacerts: @cacerts
                 ]
               ]
             ]
           }}
        ]
    end
  end
end
