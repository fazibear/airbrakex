defmodule Airbrakex.NotifierTest do
  use ExUnit.Case

  @project_id "project_id"
  @project_key "project_key"

  setup do
    bypass = Bypass.open()
    Application.put_env(:airbrakex, :endpoint, "http://localhost:#{bypass.port}")
    Application.put_env(:airbrakex, :project_id, @project_id)
    Application.put_env(:airbrakex, :project_key, @project_key)

    error =
      try do
        IO.inspect("test", [], "")
      rescue
        e -> e
      end

    {:ok, bypass: bypass, error: error}
  end

  test "notifies with a proper request", %{bypass: bypass, error: error} do
    Bypass.expect(bypass, fn conn ->
      assert "/api/v3/projects/#{@project_id}/notices" == conn.request_path
      assert "POST" == conn.method
      assert "key=#{@project_key}" == conn.query_string
      assert Enum.member?(conn.req_headers, {"content-type", "application/json"})

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error)
  end

  test "notifies with with a proper payload", %{bypass: bypass, error: error} do
    Bypass.expect(bypass, fn conn ->
      # Calling parser to populate `body_params`.
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Poison]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert Map.has_key?(conn.body_params, "notifier")
      assert Map.has_key?(conn.body_params, "errors")
      assert Map.has_key?(conn.body_params, "context")
      assert Map.has_key?(conn.body_params, "environment")

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error)
  end

  test "notifies when empty context is provided as an option", %{bypass: bypass, error: error} do
    Bypass.expect(bypass, fn conn ->
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Poison]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert "Elixir" == conn.body_params["context"]["language"]
      assert "test" == conn.body_params["context"]["environment"]

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error, context: %{})
  end

  test "notifies with session if it's provided", %{bypass: bypass, error: error} do
    Bypass.expect(bypass, fn conn ->
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Poison]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert %{"foo" => "bar"} == conn.body_params["session"]

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error, session: %{foo: "bar"})
  end

  test "notifies with additional params if they're provided", %{bypass: bypass, error: error} do
    Bypass.expect(bypass, fn conn ->
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Poison]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert %{"foo" => "bar"} == conn.body_params["params"]

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error, params: %{foo: "bar"})
  end

  test "evaluates system environment if specified", %{bypass: bypass, error: error} do
    System.put_env("AIR_TEST_ID", "airbrakex_id")
    System.put_env("AIR_TEST_KEY", "airbrakex_key")

    Application.put_env(:airbrakex, :project_id, {:system, "AIR_TEST_ID"})
    Application.put_env(:airbrakex, :project_key, {:system, "AIR_TEST_KEY"})

    Bypass.expect(bypass, fn conn ->
      assert "/api/v3/projects/airbrakex_id/notices" == conn.request_path
      assert "POST" == conn.method
      assert "key=airbrakex_key" == conn.query_string

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error)
  end
end
