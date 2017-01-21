defmodule Airbrakex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :airbrakex,
      version: "0.1.1",
      elixir: "~> 1.0",
      description: "Airbrake Elixir Notifier",
      package: package(),
      deps: deps(),
      docs: [
        main: Airbrakex,
        source_url: "https://github.com/fazibear/airbrakex"
      ]
    ]
  end

  def package() do
    [
      maintainers: ["Michał Kalbarczyk"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/fazibear/airbrakex"}
   ]
  end

  def application() do
    [
      applications: [:poison, :httpoison]
    ]
  end

  defp deps() do
    [
      {:httpoison, "~> 0.9"},
      {:poison, "~> 1.5 or ~> 2.0 or ~> 3.0"},
      {:bypass, "~> 0.1", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 0.5.0", only: :dev},
    ]
  end
end
