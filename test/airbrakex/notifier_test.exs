defmodule Airbrakex.NotifierTest do
  use ExUnit.Case

  @project_id "project_id"
  @project_key "project_key"

  defmodule SpecificError do
    defexception [:message]
  end

  def fetch_error(fun) do
    try do
      fun.()
    rescue
      e -> e
    end
  end

  setup do
    bypass = Bypass.open()
    Application.put_env(:airbrakex, :endpoint, "http://localhost:#{bypass.port}")
    Application.put_env(:airbrakex, :project_id, @project_id)
    Application.put_env(:airbrakex, :project_key, @project_key)
    Application.put_env(:airbrakex, :ignore, fn _ -> false end)

    error = fetch_error(fn -> IO.inspect("test", [], "") end)

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
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Jason]
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
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Jason]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert "Elixir" == conn.body_params["context"]["language"]
      assert "test" == conn.body_params["context"]["environment"]

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error, context: %{})
  end

  test "notifies with session if it's provided", %{bypass: bypass, error: error} do
    Bypass.expect(bypass, fn conn ->
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Jason]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert %{"foo" => "bar"} == conn.body_params["session"]

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error, session: %{foo: "bar"})
  end

  test "notifies with additional params if they're provided", %{bypass: bypass, error: error} do
    Bypass.expect(bypass, fn conn ->
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Jason]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert %{"foo" => "bar"} == conn.body_params["params"]

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error, params: %{foo: "bar"})
  end

  test "notifies with obfuscated params when set", %{bypass: bypass, error: error} do
    Application.put_env(:airbrakex, :filter_parameters, ["foo"])

    Bypass.expect(bypass, fn conn ->
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Jason]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert %{"foo" => "***"} == conn.body_params["params"]

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error, params: %{foo: "bar"})
    Application.put_env(:airbrakex, :filter_parameters, [])
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

  test "does not notify if ignore resolves truthy", %{bypass: bypass, error: error} do
    Application.put_env(:airbrakex, :ignore, fn _ -> true end)

    Bypass.pass(bypass)

    Airbrakex.Notifier.notify(error)
  end

  test "does not notify if error in ignore list", %{bypass: bypass} do
    Application.put_env(:airbrakex, :ignore, [SpecificError])

    error_to_ignore = fetch_error(fn -> raise SpecificError, "A type A error" end)

    Airbrakex.Notifier.notify(error_to_ignore)
  end

  test "notifies if error not in ignore list", %{bypass: bypass} do
    Application.put_env(:airbrakex, :ignore, [AnotherError])

    error = fetch_error(fn -> raise SpecificError, "A type A error" end)

    Bypass.expect(bypass, fn conn ->
      opts = [parsers: [Plug.Parsers.JSON], json_decoder: Jason]
      conn = Plug.Parsers.call(conn, Plug.Parsers.init(opts))

      assert "/api/v3/projects/project_id/notices" == conn.request_path
      assert "POST" == conn.method
      assert "key=project_key" == conn.query_string

      %{
        "errors" => [
          %{
            "__exception__" => true,
            "message" => message,
            "type" => type
          }
        ]
      } = conn.body_params

      assert message == "A type A error"
      assert type == "Airbrakex.NotifierTest.SpecificError"

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error)
  end

  test "accepts MFA tuple as ignore value", %{bypass: bypass, error: error} do
    defmodule IgnoreTest do
      def ignore(_error) do
        true
      end
    end

    Application.put_env(:airbrakex, :ignore, {IgnoreTest, :ignore, []})

    Bypass.pass(bypass)

    Airbrakex.Notifier.notify(error)
  end

  test "passes http_options to the HTTPoison request", %{bypass: bypass, error: error} do
    Application.put_env(:airbrakex, :http_options, params: [custom_param: "custom_value"])

    Bypass.expect(bypass, fn conn ->
      assert "/api/v3/projects/#{@project_id}/notices" == conn.request_path
      assert "POST" == conn.method
      assert "key=#{@project_key}&custom_param=custom_value" == conn.query_string

      Plug.Conn.resp(conn, 200, "")
    end)

    Airbrakex.Notifier.notify(error)
    Application.delete_env(:airbrakex, :http_options)
  end
end
