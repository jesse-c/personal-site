defmodule PersonalSite.MixProject do
  use Mix.Project

  def project do
    [
      app: :personal_site,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PersonalSite.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.6"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.14"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.5"},
      {:mnemonic_slugs, "~> 0.0.3"},
      {:bandit, "~> 1.0-pre"},
      {:nimble_publisher, "~> 1.1.0"},
      {:yaml_front_matter, "~> 1.0.0"},
      {:earmark, "~> 1.4"},
      {:makeup_diff, "~> 0.1.0"},
      {:makeup_elixir, "~> 0.16.1"},
      {:makeup_erlang, "~> 0.1.2"},
      {:makeup_json, "~> 0.1.0"},
      {:makeup_rust, "~> 0.2.0"},
      {:makeup_sql, "~> 0.1.0"},
      {:makeup_swift, "~> 0.0.2"},
      {:slugify, "~> 1.3"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:redix, "~> 1.1"},
      {:castore, ">= 0.0.0"},
      {:timex, "~> 3.7"},
      {:atomex, "0.5.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
