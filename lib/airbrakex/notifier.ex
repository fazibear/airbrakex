defmodule Airbrakex.Notifier do
  use HTTPoison.Base

  @request_headers [{"Content-Type", "application/json"}]

  @info %{
    name: "Airbrakex",
    version: Airbrakex.Mixfile.project[:version],
    url: Airbrakex.Mixfile.project[:package][:links][:github]
  }

  @context %{
    language: "Elixir",
    environment: Application.get_env(:airbrakex, :environment, :unknown)
  }

  def notify(error) do
    post(
      url,
      to_json(error),
      @request_headers
    )
  end

  def to_json(error) do
    Poison.encode! %{
      notifier: @info,
      context: @context,
      errors: [error]
    }
  end

  defp url do
    project_id = Application.get_env(:airbrakex, :project_id)
    api_key = Application.get_env(:airbrakex, :api_key)
    "http://collect.airbrake.io/api/v3/projects/#{project_id}/notices?key=#{api_key}"
  end
end
