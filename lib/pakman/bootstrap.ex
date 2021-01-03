defmodule Pakman.Bootstrap do
  alias Pakman.Environment
  alias Pakman.Bootstrap.Templates

  def perform(options) do
    workspace = System.get_env("GITHUB_WORKSPACE")

    %{organization: namespace, name: name} = Environment.repository()

    version = IO.inspect(System.cmd("git", ["describe", "--tags --always"]))
    build = IO.inspect(System.cmd("git", ["rev-list", "HEAD", "--count"]))

    base_path = Path.join(workspace, ".apk/#{namespace}/#{name}")
    config = YamlElixir.read_from_file!(Path.join(workspace, "instellar.yml"))

    System.cmd("sudo", ["chown", "-R", "builder:abuild", workspace])

    File.mkdir_p!(base_path)

    IO.inspect(create_apkbuild(base_path, name, version, build, config))
    create_file(base_path, name, :initd)
    create_file(base_path, name, :profile)
    create_file(base_path, name, :service)
    create_file(base_path, name, :pre_install)
    create_file(base_path, name, :post_install)
    create_file(base_path, name, :post_upgrade)
    create_file(base_path, name, :pre_deinstall)

    Pakman.setup()
  end

  defp create_apkbuild(base_path, name, version, build, configuration) do
    [base_path, "APKBUILD"]
    |> Enum.join("/")
    |> File.write!(
      Templates.apkbuild(
        name,
        determine_version(version),
        build,
        configuration
      )
    )
  end

  defp determine_version(version) do
    if String.match?(
         version,
         ~r/^([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)/
       ),
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
