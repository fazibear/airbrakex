defmodule Airbrakex.ExceptionParserTest do
  use ExUnit.Case

  test "should parse exception" do

    exception = try do
      IO.inspect("test",[],"")
    rescue
      e -> e
    end

    result = %{
      backtrace: [
        %{file: "(Elixir.IO) lib/io.ex", function: "inspect(\"test\", [], \"\")", line: 209},
        %{file: "(Elixir.Airbrakex.ExceptionParserTest) test/airbrakex/exception_parser_test.exs", function: "test should parse exception/1", line: 7},
        %{file: "(Elixir.ExUnit.Runner) lib/ex_unit/runner.ex", function: "exec_test/1", line: 293}, %{file: "(timer) timer.erl", function: "tc/1", line: 166},
        %{file: "(Elixir.ExUnit.Runner) lib/ex_unit/runner.ex", function: "-spawn_test/3-fun-1-/3", line: 242}
      ],
      message: "no function clause matching in IO.inspect/3",
      type: FunctionClauseError
    }

    %{
      backtrace: [],
      message: "no function clause matching in IO.inspect/3",
      type: FunctionClauseError
    }

    assert Airbrakex.ExceptionParser.parse(exception) == result
  end
end

