defmodule Airbrakex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :airbrakex,
      version: "0.2.4",
      elixir: "~> 1.0",
      description: "Airbrake Elixir Notifier",
      package: package(),
      deps: deps(),
      dialyzer: dialyzer(),
      docs: [
        main: Airbrakex,
        source_url: "https://github.com/rum-and-code/airbrakex"
      ]
    ]
  end

  def package() do
    [
      maintainers: ["Michał Kalbarczyk", "Rum&Code"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/rum-and-code/airbrakex"}
    ]
  end

  def application() do
    [
      applications: [:httpoison]
    ]
  end

  defp deps() do
    [
      {:httpoison, "~> 0.12 or ~> 1.0"},
      {:jason, "~> 1.1"},
      {:bypass, "~> 0.8", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 1.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :apps_direct,
      plt_add_apps: [:hackney, :logger, :mix],
      flags: [:error_handling, :race_conditions, :unmatched_returns]
    ]
  end
end
