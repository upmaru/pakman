defmodule Pakman.Bootstrap do
  alias Pakman.Environment
  alias Pakman.Setup
  alias Pakman.Bootstrap.Templates

  @system Application.compile_env(:pakman, :system) || System

  def perform(options \\ []) do
    workspace = System.get_env("GITHUB_WORKSPACE")

    @system.cmd("sudo", ["chown", "-R", "runner:abuild", workspace])

    %{organization: namespace, name: name, slug: slug} =
      Environment.repository()

    {version, _} = System.cmd("git", ["describe", "--tags", "--always"])

    version =
      version
      |> String.split("-")
      |> List.first()

    build = System.get_env("GITHUB_RUN_NUMBER")

    base_path = Path.join(workspace, ".apk/#{namespace}/#{name}")

    config_file =
      Keyword.get(options, :config) ||
        Path.join(workspace, "instellar.yml")

    config = YamlElixir.read_from_file!(config_file)

    options =
      if config["dependencies"]["trace"] do
        ["!check"]
      else
        ["!check", "!tracedeps"]
      end

    strip_binary = Map.get(config["build"], "strip_binary", true)

    options =
      if strip_binary == false do
        options ++ ["!strip"]
      else
        options
      end

    config =
      Map.merge(config, %{
        "options" => options,
        "dependencies" =>
          Map.merge(config["dependencies"], %{
            "runtime" =>
              merge_runtime_dependencies(
                config["dependencies"]["runtime"],
                config["type"]
              )
          })
      })

    File.mkdir_p!(base_path)

    case config["type"] do
      "custom" ->
        create_apkbuild(
          base_path,
          slug,
          String.trim(version),
          String.trim(build),
          config
        )

        create_file(base_path, slug, :pre_install)

        Map.get(config, "hook", %{})
        |> Enum.map(&create_hook_file(&1, base_path, slug))

      _ ->
        create_apkbuild(
          base_path,
          slug,
          String.trim(version),
          String.trim(build),
          config
        )

        if run_config = Map.get(config, "run") do
          create_life_cycle_files(base_path, run_config)
        end

        create_build_files(base_path, slug, config["type"])

        Map.get(config, "hook", %{})
        |> Enum.map(&create_hook_file(&1, base_path, slug))
    end

    Setup.perform()
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

  defp merge_runtime_dependencies(nil, type),
    do: merge_runtime_dependencies([], type)

  defp merge_runtime_dependencies(original, "static") when is_list(original),
    do: original ++ ["nginx"]

  defp merge_runtime_dependencies(original, _) when is_list(original),
    do: original

  defp create_build_files(base_path, name, "static"),
    do: create_file(base_path, name, :pre_install)

  defp create_build_files(base_path, name, _) do
    create_file(base_path, name, :profile)
    create_file(base_path, name, :pre_install)
    create_file(base_path, name, :environment)
    create_file(base_path, name, :env_exec)
  end

  def create_life_cycle_files(base_path, %{"name" => name} = configuration) do
    [base_path, "#{name}.initd"]
    |> Path.join()
    |> File.write!(Templates.initd(configuration))

    [base_path, "#{name}.run"]
    |> Path.join()
    |> File.write!(Templates.run(configuration))

    [base_path, "#{name}.log"]
    |> Path.join()
    |> File.write!(Templates.log(name))
  end

  defp create_hook_file({hook_name, content}, base_path, name) do
    [base_path, "#{name}.#{hook_name}"]
    |> Path.join()
    |> File.write!(Templates.hook(content))
  end

  defp create_file(base_path, name, type) do
    file_type = generate_file_type(type)

    [base_path, "#{name}.#{file_type}"]
    |> Path.join()
    |> File.write!(apply(Templates, type, [name]))
  end

  defp generate_file_type(type) do
    type
    |> Atom.to_string()
    |> String.replace("_", "-")
  end
end
