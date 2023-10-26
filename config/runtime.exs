import Config

config :tesla,
       :adapter,
       {Tesla.Adapter.Finch, name: Pakman.Finch, receive_timeout: 30_000}

config :ex_aws,
  http_client: Pakman.ExAws.Client
