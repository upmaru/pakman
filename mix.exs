defmodule Pakman.MixProject do
  use Mix.Project

  def project do
    [
      app: :pakman,
      version: "7.2.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      escript: [
        main_module: Pakman.CLI,
        path: "bin/pakman"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Pakman.Application, []},
      extra_applications: [:logger, :eex]
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/fixture"]
  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.7.0"},
      {:jason, ">= 1.0.0"},
      {:yaml_elixir, "~> 2.8.0"},
      {:slugger, "~> 0.3.0"},
      {:finch, "~> 0.14.0"},
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
