defmodule Airbrakex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :airbrakex,
      version: "0.0.6",
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
      applications: [:idna, :hackney, :httpoison]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8"},
      {:poison, "~> 1.5"}
    ]
  end
end
