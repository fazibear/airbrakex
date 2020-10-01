defmodule Airbrakex.LoggerBackend do
  @moduledoc """
  A Logger backend to send exceptions from logs to the `airbrake`

  ## Usage

  ```elixir
  config :logger,
    backends: [Airbrakex.LoggerBackend]
  ```
  """

  @behaviour :gen_event

  alias Airbrakex.{LoggerParser, Notifier}

  def init(__MODULE__) do
    {:ok, configure([])}
  end

  def handle_call({:configure, opts}, _state) do
    {:ok, :ok, configure(opts)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, event}, %{metadata: keys} = state) do
    if proceed?(event) and meet_level?(level, state.level) do
      post_event(event, keys)
    end

    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_info(_message, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp proceed?({Logger, _msg, _ts, meta} = log) do
    Keyword.get(meta, :airbrakex, true) and
      not ignore_backend?(Application.get_env(:airbrakex, :ignore_backend), log)
  end

  defp ignore_backend?(ignore, _error) when is_nil(ignore), do: false
  defp ignore_backend?({module, function, []}, log), do: apply(module, function, [log])
  defp ignore_backend?(ignore, log) when is_function(ignore), do: ignore.(log)

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp post_event({Logger, msg, _ts, meta}, keys) do
    msg = IO.chardata_to_string(msg)
    meta = take_into_map(meta, keys)

    msg
    |> LoggerParser.parse()
    |> Notifier.notify(params: meta)
  end

  defp take_into_map(metadata, keys) do
    Enum.reduce(metadata, %{}, fn {key, val}, acc ->
      if key in keys, do: Map.put(acc, key, val), else: acc
    end)
  end

  defp configure(opts) do
    config =
      :logger
      |> Application.get_env(__MODULE__, [])
      |> Keyword.merge(opts)

    Application.put_env(:logger, __MODULE__, config)

    %{
      level: Application.get_env(:airbrakex, :logger_level, :error),
      metadata: Keyword.get(config, :metadata, [])
    }
  end
end
