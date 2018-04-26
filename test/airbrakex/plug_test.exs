defmodule Airbrakex.TestPlug do
  use Airbrakex.Plug

  def call(_conn, _opts) do
    IO.inspect("test", [], "")
  end
end

defmodule Airbrakex.PlugTest do
  use Airbrakex.TestCase
  use Plug.Test

  test "notifies with request url in context" do
    notify fn -> Airbrakex.TestPlug.call(conn(:get, "/wat"), %{}) end, fn _conn, params ->
      %{"context" => context} = params
      assert "http://www.example.com/wat" == Map.get(context, "url")
    end
  end
end
