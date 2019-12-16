defmodule Apkify.Bootstrap do
  @apkbuild "apkbuild.eex"
  @workspace System.get_env(~s(GITHUB_WORKSPACE))

  def perform(options) do
    [namespace, name] =
      options
      |> Keyword.get(:repository)
      |> String.split("/")

    version = Keyword.get(options, :version)
    build = Keyword.get(options, :build)

    base_path = ".apk/#{namespace}/#{name}"
    File.mkdir_p(base_path)

    [@workspace, base_path, "APKBUILD"]
    |> Enum.join("/")
    |> File.write(Templates.apkbuild(name, version, build))
  end
end
