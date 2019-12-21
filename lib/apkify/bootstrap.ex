defmodule Apkify.Bootstrap do
  alias Apkify.Templates

  def perform(options) do
    workspace = System.get_env("GITHUB_WORKSPACE")

    [namespace, name] =
      ~s(GITHUB_REPOSITORY)
      |> System.get_env()
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
    create_file(base_path, name, :pre_install)
    create_file(base_path, name, :post_install)
    create_file(base_path, name, :post_upgrade)
    create_file(base_path, name, :pre_deinstall)
  end

  defp create_apkbuild(base_path, name, version, build, depends, makedepends) do
    [base_path, "APKBUILD"]
    |> Enum.join("/")
    |> File.write!(
      Templates.apkbuild(name, determine_version(version), build, depends, makedepends)
    )
  end

  defp determine_version(version) do
    if String.match?(version, ~r/^([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)/),
      do: version,
      else: "0.0.0"
  end

  defp create_file(base_path, name, type) do
    file_type =
      type
      |> Atom.to_string()
      |> String.replace("_", "-")

    [base_path, "#{name}.#{file_type}"]
    |> Enum.join("/")
    |> File.write!(apply(Templates, type, [name]))
  end
end
