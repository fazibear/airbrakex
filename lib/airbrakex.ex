defmodule Airbrakex do
  def notify(exception, options \\ []) do
    Airbrakex.ExceptionParser.parse(exception) |> Airbrakex.Notifier.notify(options)
  end
end
