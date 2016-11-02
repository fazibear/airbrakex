defmodule Airbrakex do
  @moduledoc """
  This module provides functions to report any kind of exception to
  [Airbrake](https://airbrake.io/).

  ### Configuration

  It requires `project_key` and `project` parameters to be set
  in your application environment, usually defined in your `config/config.exs`.
  `logger_level` and `environment` are optional.
  If you want to use errbit instance, set custom url as endpoint.

  ```elixir
  config :airbrakex,
    project_key: "abcdef12345",
    project_id: 123456,
    logger_level: :error,
    environment: Mix.env,
    endpoint: "http://errbit.yourdomain.com"
  ```

  ## Usage

  ```elixir
  try do
    IO.inspect("test",[],"")
  rescue
    exception -> Airbrakex.notify(exception)
  end
  ```

  You can ignore certain types of errors by specifying `:ignore` config key:

  ```elixir
  config :airbrakex,
    ...
    # List form
    ignore: [Phoenix.Router.NoRouteError]
    # OR
    # Function
    ignore: fn(error) ->
      cond do
        error.type == Phoenix.Router.NoRouteError -> true
        String.contains?(error.message, "Ecto.NoResultsError") -> true
        true -> false
      end
    end
  ```
  """

  @doc """
  Notify `airbrake` obout new exception

  ## Parameters

    - exception: Exception to nitify
    - options: Options

  ## Options

  Options that are sent do `airbrake` with execptions:

    - context
    - session
    - params
    - environment
  """
  def notify(exception, options \\ []) do
    Airbrakex.ExceptionParser.parse(exception) |> Airbrakex.Notifier.notify(options)
  end
end
