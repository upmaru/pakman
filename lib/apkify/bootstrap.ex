defmodule Apkify.Bootstrap do
  @apkbuild "lib/apk/templates/apkbuild.eex"

  def perform(options) do
    %{namespace: namespace, name: name} = Keyword.get(options, :repository)
    version = Keyword.get(options, :version)
    build = Keyword.get(options, :build)

    base_path = ".apk/#{namespace}/#{name}"
    File.mkdir_p(base_path)

    [base_path, "APKBUILD"]
    |> Enum.join("/")
    |> File.write(render_apkbuild(name, version, build))
  end

  defp render_apkbuild(name, version, build) do
    EEx.eval_file(@apkbuild, app_name: name, version: version, build: build)
  end
end