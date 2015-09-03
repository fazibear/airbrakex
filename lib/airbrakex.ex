defmodule Airbrakex do
  def notify(exception) do
    Airbrakex.ExceptionParser.parse(exception) |> Airbrakex.Notifier.notify
  end
end
