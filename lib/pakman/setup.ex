defmodule Pakman.Setup do
  alias Pakman.Environment

  @system Application.compile_env(:pakman, :system) || System

  @etc_apk_keys "/etc/apk/keys"

  def perform do
    home = System.get_env("HOME")
    private_key = System.get_env("ABUILD_PRIVATE_KEY")
    public_key = System.get_env("ABUILD_PUBLIC_KEY")

    %{organization: namespace, name: _name, slug: slug} =
      Environment.repository()

    key_name = Enum.join([namespace, slug], "-")

    @system.cmd("sudo", ["chown", "-R", "runner:abuild", home])

    abuild_config_path = Path.join(home, ".abuild")

    File.mkdir_p!(abuild_config_path)

    abuild_config_path
    |> Path.join("abuild.conf")
    |> File.write!(render_conf(home, key_name))

    abuild_config_path
    |> Path.join("#{key_name}.rsa")
    |> File.write!(private_key)

    abuild_config_path
    |> Path.join("#{key_name}.rsa.pub")
    |> File.write!(public_key)

    @etc_apk_keys
    |> Path.join("#{key_name}.rsa.pub")
    |> File.write!(public_key)
  end

  defp render_conf(home, key_name),
    do: """
    PACKAGER_PRIVKEY=#{home}/.abuild/#{key_name}.rsa
    """
end
