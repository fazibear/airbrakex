defmodule Airbrakex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :airbrakex,
      version: "0.0.10",
      elixir: "~> 1.0",
      description: "Airbrake Elixir Notifier",
      package: package,
      deps: deps
   ]
  end

  def package do
    [
      maintainers: ["Michał Kalbarczyk"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/fazibear/airbrakex"}
   ]
  end

  def application do
    [
      applications: [:poison, :httpoison]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9"},
      {:poison, "~> 1.5 or ~> 2.0"},
      {:bypass, "~> 0.1", only: :test}
    ]
  end
end
