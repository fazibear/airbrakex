defmodule Airbrakex.LoggerBackend do
  use GenEvent

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

  defp proceed?({Logger, _msg, _ts, meta}) do
    Keyword.get(meta, :airbrakex, true)
  end

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp post_event({Logger, msg, _ts, meta}, keys) do
    msg = IO.chardata_to_string(msg)
    meta = take_into_map(meta, keys)
    Airbrakex.LoggerParser.parse(msg) |> Airbrakex.Notifier.notify([params: meta])
  end

  defp take_into_map(metadata, keys) do
    Enum.reduce metadata, %{}, fn({key, val}, acc) ->
      if key in keys, do: Map.put(acc, key, val), else: acc
    end
  end

  defp configure(opts) do
    config = Application.get_env(:logger, __MODULE__, []) |> Keyword.merge(opts)

    Application.put_env(:logger, __MODULE__, config)

    %{
      level: Application.get_env(:airbrakex, :logger_level, :error),
      metadata: Keyword.get(config, :metadata, [])
    }
  end
end
