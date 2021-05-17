defmodule Airbrakex.ExceptionParserTest do
  use ExUnit.Case

  test "parses exception" do
    {exception, stacktrace} =
      try do
        IO.inspect("test", [], "")
      rescue
        e -> {e, __STACKTRACE__}
      end

    parsed_exception = Airbrakex.ExceptionParser.parse(exception, stacktrace)

    backtrace = parsed_exception[:backtrace]
    message = parsed_exception[:message]
    type = parsed_exception[:type]

    assert type == FunctionClauseError
    assert message == "no function clause matching in IO.inspect/3"

    backtrace_files = Enum.map(backtrace, fn entry -> entry[:file] end)

    assert Enum.member?(backtrace_files, "(Elixir.IO) lib/io.ex")

    assert Enum.member?(
             backtrace_files,
             "(Elixir.Airbrakex.ExceptionParserTest) test/airbrakex/exception_parser_test.exs"
           )

    assert Enum.member?(backtrace_files, "(timer) timer.erl")
    assert Enum.member?(backtrace_files, "(Elixir.ExUnit.Runner) lib/ex_unit/runner.ex")

    backtrace_functions = Enum.map(backtrace, fn entry -> entry[:function] end)

    assert Enum.member?(backtrace_functions, "inspect(\"test\", [], \"\")")
    assert Enum.member?(backtrace_functions, "test parses exception/1")
    assert Enum.member?(backtrace_functions, "exec_test/1")
    assert Enum.member?(backtrace_functions, "tc/1")

    compare = &Version.compare(System.version(), &1)

    spawn_test =
      if :lt == compare.("1.6.0") do
        "-spawn_test/3-fun-1-/3"
      else
        if :lt == compare.("1.8.0") do
          "-spawn_test/3-fun-1-/4"
        else
          "-spawn_test_monitor/4-fun-1-/4"
        end
      end

    assert Enum.member?(backtrace_functions, spawn_test)
  end
end
