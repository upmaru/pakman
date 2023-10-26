defmodule Pakman.ExAws.Client do
  @behaviour ExAws.Request.HttpClient
  def request(method, url, body, headers, _http_opts) do
    [{Tesla.Middleware.Logger, debug: false}]
    |> Tesla.client(
      {Tesla.Adapter.Finch, name: Pakman.Finch, receive_timeout: 30_000}
    )
    |> Tesla.request(method: method, url: url, body: body, headers: headers)
  end
end
