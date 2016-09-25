defmodule Airbrakex.Notifier do
  @moduledoc false
  use HTTPoison.Base
  alias Airbrakex.Config

  @request_headers [{"Content-Type", "application/json"}]
  @default_endpoint "http://collect.airbrake.io"
  @default_env Mix.env

  @info %{
    name: "Airbrakex",
    version: Airbrakex.Mixfile.project[:version],
    url: Airbrakex.Mixfile.project[:package][:links][:github]
  }

  def notify(error, options \\ []) do
    payload = %{}
    |> add_notifier
    |> add_error(error)
    |> add_context(Keyword.get(options, :context))
    |> add(:session, Keyword.get(options, :session))
    |> add(:params, Keyword.get(options, :params))
    |> add(:environment, Keyword.get(options, :environment, %{}))
    |> Poison.encode!

    post(url, payload, @request_headers)
  end

  defp add_notifier(payload) do
    payload |> Map.put(:notifier, @info)
  end

  defp add_error(payload, nil), do: payload
  defp add_error(payload, error) do
    payload |> Map.put(:errors, [error])
  end

  defp add_context(payload, nil) do
    payload |> Map.put(:context, %{environment: environment})
  end

  defp add_context(payload, context) do
    context = context
    |> Map.put_new(:environment, environment)
    |> Map.put_new(:language, "Elixir")

    payload |> Map.put(:context, context)
  end

  defp add(payload, _key, nil), do: payload
  defp add(payload, key, value), do: payload |> Map.put(key, value)

  defp url do
    project_id = Config.get(:airbrakex, :project_id)
    project_key = Config.get(:airbrakex, :project_key)
    endpoint = Config.get(:airbrakex, :endpoint, @default_endpoint)

    "#{endpoint}/api/v3/projects/#{project_id}/notices?key=#{project_key}"
  end

  defp environment do
    Config.get(:airbrakex, :environment, @default_env)
  end
end
