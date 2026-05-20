defmodule Pakman.ExAws.Client do
  @behaviour ExAws.Request.HttpClient

  def request(method, url, body, headers, _http_opts) do
    Req.request(
      [
        method: method,
        url: url,
        body: body,
        headers: headers
      ] ++ Pakman.Http.options()
    )
  end
end
