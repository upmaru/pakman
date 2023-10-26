defmodule Pakman.ExAws.Client do
  @behaviour ExAws.Request.HttpClient
  def request(method, url, body, headers, _http_opts) do
    [{Tesla.Middleware.Logger, debug: false}]
    |> Tesla.client()
    |> Tesla.request(method: method, url: url, body: body, headers: headers)
  end
end
