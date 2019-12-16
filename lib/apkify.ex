defmodule Apkify do
  @moduledoc """
  Documentation for Apkify.
  """

  def template(name) do
    Path.join(:code.priv_dir(:apkify), ["templates", "/", name])
  end
end
