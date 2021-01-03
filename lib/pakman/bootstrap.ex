defmodule Pakman.Bootstrap do
  alias Pakman.Environment
  alias Pakman.Bootstrap.Templates

  def perform(options) do
    workspace = System.get_env("GITHUB_WORKSPACE")

    %{organization: namespace, name: name} = Environment.repository()

    {version, 0} = System.cmd("git", ["describe", "--tags", "--always"])

    {build, 0} = System.cmd("git", ["rev-list", "HEAD", "--count"])

    base_path = Path.join(workspace, ".apk/#{namespace}/#{name}")
    config = YamlElixir.read_from_file!(Path.join(workspace, "instellar.yml"))

    config =
      Map.merge(config, %{
        "dependencies" =>
          Map.merge(Map.get(config["dependencies"], %{}), %{
            "runtime" =>
              config["dependencies"]["runtime"] ++
                base_runtime_dependencies(config["type"])
          })
      })

    System.cmd("sudo", ["chown", "-R", "builder:abuild", workspace])

    File.mkdir_p!(base_path)

    create_apkbuild(
      base_path,
      name,
      String.trim(version),
      String.trim(build),
      config
    )

    create_build_files(base_path, name, config["type"])

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

  defp base_runtime_dependencies("static"), do: ["nginx"]
  defp base_runtime_dependencies(_), do: []

  defp create_build_files(base_path, name, "static") do
    create_file(base_path, name, :pre_install)
    create_file(base_path, name, :post_install)
    create_file(base_path, name, :post_upgrade)
    create_file(base_path, name, :pre_deinstall)
  end

  defp create_build_files(base_path, name, _) do
    create_file(base_path, name, :initd)
    create_file(base_path, name, :profile)
    create_file(base_path, name, :service)
    create_file(base_path, name, :pre_install)
    create_file(base_path, name, :post_install)
    create_file(base_path, name, :post_upgrade)
    create_file(base_path, name, :pre_deinstall)
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
