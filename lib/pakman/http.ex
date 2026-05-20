defmodule Pakman.Http do
  def options do
    [
      connect_options: [
        transport_opts: [
          cacerts: :public_key.cacerts_get()
        ]
      ],
      retry: false
    ]
  end
end
