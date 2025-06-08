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
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.5"},
      {:mnemonic_slugs, "~> 0.0.3"},
      {:bandit, "~> 1.0-pre"},
      {:nimble_publisher, "~> 1.1.0"},
      {:yaml_front_matter, "~> 1.0.0"},
      {:autumn, "~> 0.3.2"},
      {:mdex, "~> 0.7.0"},
      {:slugify, "~> 1.3"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:redix, "~> 1.1"},
      {:castore, ">= 0.0.0"},
      {:timex, "~> 3.7"},
      {:atomex, "0.5.1"},
      {:sentry, "~> 10.10.0"},
      {:hackney, "~> 1.23.0"},
      {:tzdata, "~> 1.1"},
      {:hammer, "~> 7.0"},
      {:nx, "~> 0.9.0"},
      {:tesla, "~> 1.12"},
      {:req, "~> 0.5.0"},
      {:dotenvy, "~> 1.1.0"},
      {:earmark, "1.5.0-pre1", override: true}
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
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "feed",
        "phx.digest"
      ],
      open: [fn _ -> Mix.shell().cmd("open http://localhost:4000") end],
      server: ["phx.server"]
    ]
  end
end
