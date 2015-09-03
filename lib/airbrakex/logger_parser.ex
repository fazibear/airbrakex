defmodule Airbrakex.LoggerParser do
  @stacktrace_regex ~r/^\s*(?<file>\([^()]+\)\s+[^:]+):(?<line>\d+):(?<function>.*)/m
  @type_regex ~r/^\s*\*\*\s*\((?<type>[^()]+)\)/m
  @exception_header_regex ~r/an exception was raised:/

  def parse(msg) do
    type = Regex.named_captures(@type_regex, msg)["type"]

    messages = Enum.filter_map String.split(msg, "\n"), &(!Regex.match?(@stacktrace_regex, &1) && !Regex.match?(@exception_header_regex, &1)), fn(line) ->
      Regex.replace(@type_regex, line, "")
    end

    backtrace = Enum.filter_map String.split(msg, "\n"), &(Regex.match?(@stacktrace_regex, &1)), fn(line) ->
      hash = Regex.named_captures(@stacktrace_regex, line)
      { line, _ } = Integer.parse(hash["line"])
      %{ hash | "line" => line }
    end

    %{
      type: type,
      message: Enum.join(messages, "\n"),
      backtrace: backtrace
    }
  end
end
