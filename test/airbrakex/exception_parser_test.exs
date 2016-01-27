defmodule Airbrakex.ExceptionParserTest do
  use ExUnit.Case

  test "should parse exception" do
    exception = try do
      IO.inspect("test",[],"")
    rescue
      e -> e
    end

    expected = %{
      backtrace: [],
      message: "no function clause matching in IO.inspect/3",
      type: FunctionClauseError
    }
    actual = Airbrakex.ExceptionParser.parse(exception)

    assert [_head | _tail] = actual.backtrace
    assert actual.message == expected.message
    assert actual.type == expected.type
  end
end

