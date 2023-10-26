defmodule Pakman.ExAws.Client do

  @behaviour ExAws.Request.HttpClient
  def request(method, url, body, headers, _http_opts) do
    client = Tesla.client([])

    Tesla.request(client, method: method, url: url, body: body, headers: headers)
  end
end