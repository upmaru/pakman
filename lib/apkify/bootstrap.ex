defmodule Apkify.Bootstrap do
  alias Apkify.Templates

  @workspace System.get_env(~s(GITHUB_WORKSPACE))

  def perform(options) do
    [namespace, name] =
      options
      |> Keyword.get(:repository)
      |> String.split("/")

    version = Keyword.get(options, :version)
    build = Keyword.get(options, :build)
    depends = Keyword.get(options, :depends)
    makedepends = Keyword.get(options, :makedepends)

    base_path = ".apk/#{namespace}/#{name}"
    File.mkdir_p(base_path)

    create_apkbuild(base_path, name, version, build, depends, makedepends)
  end

  defp create_apkbuild(base_path, name, version, build, depends, makedepends) do
    [@workspace, base_path, "APKBUILD"]
    |> Enum.join("/")
    |> File.write(Templates.apkbuild(name, version, build, depends, makedepends))
  end
end
