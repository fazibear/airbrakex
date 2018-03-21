defmodule Airbrakex.Config do
  @moduledoc """
  This module handles smart fetching values from the config
  """

  @doc """
  Fetches a value from config, or environment if {:system, "VAR"} is provided.
  An optional default value can be provided, if desired.
  """
  @spec get(atom, atom, term | nil) :: term
  def get(app, key, default \\ nil) when is_atom(app) and is_atom(key) do
    app
    |> Application.get_env(key)
    |> get_config(default)
  end

  defp get_config({:system, env_var}, default) do
    case env_var |> System.get_env() do
      nil ->
        default

      value ->
        value
    end
  end

  defp get_config({:system, env_var, preconfigured_default}, _default) do
    case env_var |> System.get_env() do
      nil ->
        preconfigured_default

      value ->
        value
    end
  end

  defp get_config(nil, default), do: default
  defp get_config(value, _default), do: value
end
