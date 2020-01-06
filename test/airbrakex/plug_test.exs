defmodule Airbrakex.TestPlug do
  use Airbrakex.Plug

  def call(_conn, _opts) do
    IO.inspect("test", [], "")
  end
end

defmodule Airbrakex.PlugTest do
  use ExUnit.Case
  use Plug.Test

  @project_id "project_id"
  @project_key "project_key"

  setup do
    bypass = Bypass.open()
    Application.put_env(:airbrakex, :endpoint, "http://localhost:#{bypass.port}")
    Application.put_env(:airbrakex, :project_id, @project_id)
    Application.put_env(:airbrakex, :project_key, @project_key)
    Application.put_env(:airbrakex, :ignore, fn _ -> false end)

    error =
      try do
        IO.inspect("test", [], "")
      rescue
        e -> e
      end

    {:ok, bypass: bypass, error: error}
  end

  test "returns hello world", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Jason]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert %{"context" => %{"url" => "http://www.example.com/hello"}} = conn.body_params

      Plug.Conn.resp(conn, 200, "")
    end)


    conn = conn(:get, "/hello")
    |> fetch_query_params()

    try do
      Airbrakex.TestPlug.call(conn, [])
    rescue
      e in FunctionClauseError -> e
    end
  end
end
