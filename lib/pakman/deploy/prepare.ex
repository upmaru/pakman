defmodule Pakman.Deploy.Prepare do
  alias Pakman.Environment
  alias Pakman.Deploy.Templates

  def perform(_options) do
    workspace = System.get_env("GITHUB_WORKSPACE")
    public_key = System.get_env("ABUILD_PUBLIC_KEY")
    package_token = System.get_env("INSTELLAR_PACKAGE_TOKEN")
    branch = Environment.branch()
    %{name: name} = Environment.repository()

    System.cmd("sudo", ["chown", "-R", "builder:abuild", workspace])

    File.mkdir_p!(~s(deploy))

    create_setup(name, branch, package_token)

    ~s(deploy)
    |> Path.join("pakman.rsa.pub")
    |> File.write!(public_key)
  end

  defp create_setup(name, branch, package_token) do
    ["deploy", "setup.start"]
    |> Path.join()
    |> File.write!(Templates.local_d_setup(name, branch, package_token))
  end
end
