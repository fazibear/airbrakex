defmodule Airbrakex.Notifier do
  @moduledoc false
  use HTTPoison.Base
  alias Airbrakex.Config

  @request_headers [{"Content-Type", "application/json"}]
  @default_endpoint "https://airbrake.io"
  @default_env Mix.env()

  @info %{
    name: "Airbrakex",
    version: Airbrakex.Mixfile.project()[:version],
    url: Airbrakex.Mixfile.project()[:package][:links][:github]
  }

  def notify(error, options \\ []) do
    if proceed?(Application.get_env(:airbrakex, :ignore), error) do
      payload =
        %{}
        |> add_notifier
        |> add_error(error)
        |> add_context(Keyword.get(options, :context))
        |> add(:session, Keyword.get(options, :session))
        |> add(:params, Keyword.get(options, :params))
        |> add(:environment, Keyword.get(options, :environment, %{}))
        |> Jason.encode!()

      post(url(), payload, @request_headers, http_options())
    end
  end

  defp add_notifier(payload) do
    payload |> Map.put(:notifier, @info)
  end

  defp add_error(payload, nil), do: payload

  defp add_error(payload, error) do
    error = Map.from_struct(error)

    payload |> Map.put(:errors, [error])
  end

  defp add_context(payload, nil) do
    payload |> Map.put(:context, %{environment: environment()})
  end

  defp add_context(payload, context) do
    context =
      context
      |> Map.put_new(:environment, environment())
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

  defp http_options do
    Config.get(:airbrakex, :http_options) || []
  end

  defp environment do
    Config.get(:airbrakex, :environment, @default_env)
  end

  defp proceed?(ignore, _error) when is_nil(ignore), do: true
  defp proceed?({module, function, []}, error), do: !apply(module, function, [error])
  defp proceed?(ignore, error) when is_function(ignore), do: !ignore.(error)
  defp proceed?(ignore, _error) when is_boolean(ignore), do: !ignore

  defp proceed?(ignore, error) when is_list(ignore),
    do: !Enum.any?(ignore, fn el -> el == error.type end)
end
