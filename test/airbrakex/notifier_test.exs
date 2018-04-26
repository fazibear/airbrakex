defmodule Airbrakex.NotifierTest do
  use Airbrakex.TestCase

  test "notifies with a proper request" do
    notify fn conn, _params ->
      assert "/api/v3/projects/project_id/notices" == conn.request_path
      assert "POST" == conn.method
      assert "key=project_key" == conn.query_string
      assert Enum.member?(conn.req_headers, {"content-type", "application/json"})
    end
  end

  test "notifies with a proper payload" do
    notify fn _conn, params ->
      assert Map.has_key?(params, "notifier")
      assert Map.has_key?(params, "errors")
      assert Map.has_key?(params, "context")
      assert Map.has_key?(params, "environment")
    end
  end

  test "adds language to context" do
    notify fn -> Airbrakex.Notifier.notify(error(), context: %{mystuff: "Yo!"}) end, fn _conn, params ->
      assert "Elixir" == params["context"]["language"]
    end
  end

  test "adds environment to context" do
    notify fn -> Airbrakex.Notifier.notify(error(), context: %{mystuff: "Yo!"}) end, fn _conn, params ->
      assert "test" == params["context"]["environment"]
    end
  end

  test "keeps provided context" do
    notify fn -> Airbrakex.Notifier.notify(error(), context: %{mystuff: "Yo!"}) end, fn _conn, params ->
      assert "Yo!" == params["context"]["mystuff"]
    end
  end

  test "notifies with session if it's provided" do
    notify fn -> Airbrakex.Notifier.notify(error(), session: %{foo: "bar"}) end, fn _conn, params ->
      assert %{"foo" => "bar"} == params["session"]
    end
  end

  test "notifies with additional params if they're provided" do
    notify fn -> Airbrakex.Notifier.notify(error(), params: %{foo: "bar"}) end, fn _conn, params ->
      assert %{"foo" => "bar"} == params["params"]
    end
  end

  test "evaluates system environment if specified" do
    System.put_env("AIR_TEST_ID", "airbrakex_id")
    System.put_env("AIR_TEST_KEY", "airbrakex_key")

    notify {:system, "AIR_TEST_ID"}, {:system, "AIR_TEST_KEY"}, fn conn, _params ->
      assert "/api/v3/projects/airbrakex_id/notices" == conn.request_path
      assert "POST" == conn.method
      assert "key=airbrakex_key" == conn.query_string
    end
  end
end
