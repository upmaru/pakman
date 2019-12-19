defmodule Apkify.Bootstrap do
  alias Apkify.Templates

  def perform(options) do
    workspace = System.get_env("GITHUB_WORKSPACE")

    [namespace, name] =
      options
      |> Keyword.get(:repository)
      |> String.split("/")

    version = Keyword.get(options, :version)
    build = Keyword.get(options, :build)
    depends = Keyword.get(options, :depends)
    makedepends = Keyword.get(options, :makedepends)
    runtime_vars = Keyword.get(options, :runtime_vars)

    base_path = Path.join(workspace, ".apk/#{namespace}/#{name}")

    System.cmd("sudo", ["chown", "-R", "builder:abuild", workspace])

    File.mkdir_p!(base_path)

    create_apkbuild(base_path, name, version, build, depends, makedepends)
    create_file(base_path, name, :initd)
    create_file(base_path, name, :profile)
    create_file(base_path, name, :service)
    create_config(base_path, name, runtime_vars)
  end

  defp create_config(base_path, name, runtime_vars) do
    [base_path, "#{name}.config"]
    |> Enum.join("/")
    |> File.write(Templates.config(name, runtime_vars))
  end

  defp create_apkbuild(base_path, name, version, build, depends, makedepends) do
    [base_path, "APKBUILD"]
    |> Enum.join("/")
    |> File.write(Templates.apkbuild(name, version, build, depends, makedepends))
  end

  defp create_file(base_path, name, type) do
    [base_path, "#{name}.#{type}"]
    |> Enum.join("/")
    |> File.write(apply(Templates, type, [name]))
  end
end
