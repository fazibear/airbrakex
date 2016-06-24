defmodule Airbrakex.Notifier do
  use HTTPoison.Base

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
    Map.put(payload, :notifier, @info)
  end

  defp add_error(payload, nil), do: payload
  defp add_error(payload, error) do
    Map.put(payload, :errors, [error])
  end

  defp add_context(payload, nil) do
    Map.put(payload, :context, %{environment: env()})
  end

  defp add_context(payload, context) do
    context = context
    |> Map.put_new(:environment, env())
    |> Map.put_new(:language, "Elixir")

    Map.put(payload, :context, context)
  end

  defp add(payload, _key, nil), do: payload
  defp add(payload, key, value), do: Map.put(payload, key, value)

  defp url do
    project_id = Application.get_env(:airbrakex, :project_id)
    project_key = Application.get_env(:airbrakex, :project_key)
    endpoint = Application.get_env(:airbrakex, :endpoint, @default_endpoint)

    "#{endpoint}/api/v3/projects/#{project_id}/notices?key=#{project_key}"
  end

  defp env do
    Application.get_env(:airbrakex, :environment, @default_env)
  end
end
