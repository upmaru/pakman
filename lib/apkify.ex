defmodule Apkify do
  @moduledoc """
  Documentation for Apkify.
  """
  def setup_keys do
    home = System.get_env("HOME")
    private_key = System.get_env("ABUILD_PRIVATE_KEY")
    public_key = System.get_env("ABUILD_PUBLIC_KEY")

    abuild_config_path = Path.join(home, ".abuild")

    abuild_config_path
    |> Path.join("apkify.rsa")
    |> File.write(private_key)

    abuild_config_path
    |> Path.join("apkify.rsa.pub")
    |> File.write(public_key)
  end
end
