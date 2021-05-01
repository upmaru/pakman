defmodule Pakman.MixProject do
  use Mix.Project

  def project do
    [
      app: :pakman,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [
        main_module: Pakman.CLI,
        path: "bin/pakman"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.3.1"},
      {:jason, ">= 1.0.0"},
      {:yaml_elixir, "~> 2.5.0"},
      {:slugger, "~> 0.3.0"},
      {:mint, "~> 1.0"},
      {:castore, "~> 0.1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
