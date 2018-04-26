ExUnit.start()

Application.ensure_all_started(:bypass)

defmodule Airbrakex.TestCase do
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      import Airbrakex.TestCase
    end
  end

  def error do
    try do error!() rescue e -> e end
  end

  def error! do
    IO.inspect("test", [], "")
  end

  def body_params(conn) do
    opts = [parsers: [Plug.Parsers.JSON], json_decoder: Poison]
    Plug.Parsers.call(conn, Plug.Parsers.init(opts)).body_params
  end

  def notify(verify) do
    verify_airbrake_notification(verify)
    Airbrakex.Notifier.notify(error())
  end

  def notify(work, verify) do
    verify_airbrake_notification(verify)
    try do work.() rescue e -> e end
  end

  def notify(project_id, project_key, verify) do
    verify_airbrake_notification(project_id, project_key, verify)
    Airbrakex.Notifier.notify(error())
  end

  defp bypass_airbrake(project_id, project_key) do
    bypass = Bypass.open()
    Application.put_env(:airbrakex, :endpoint, "http://localhost:#{bypass.port}")
    Application.put_env(:airbrakex, :project_id, project_id)
    Application.put_env(:airbrakex, :project_key, project_key)
    bypass
  end

  defp verify_airbrake_notification(project_id \\ "project_id", project_key \\ "project_key", verify) do
    Bypass.expect(bypass_airbrake(project_id, project_key), fn conn ->
      verify.(conn, body_params(conn))
      Plug.Conn.resp(conn, 200, "")
    end)
  end
end