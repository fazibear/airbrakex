defmodule Airbrakex.LoggerParser do
  @moduledoc false
  @stacktrace_regex ~r/^\s*(?<file>\([^()]+\)\s+[^:]+):(?<line>\d+):(?<function>.*)/m
  @type_regex ~r/^\s*\*\*\s*\((?<type>[^()]+)\)/m
  @exception_header_regex ~r/an exception was raised:/

  def parse(msg) do
    type = Regex.named_captures(@type_regex, msg)["type"]
    lines = String.split(msg, "\n")

    message =
      lines
      |> Enum.filter(&message?/1)
      |> Enum.map(fn line -> Regex.replace(@type_regex, line, "") end)
      |> Enum.join("\n")

    backtrace =
      lines
      |> Enum.filter(&stacktrace?/1)
      |> Enum.map(&backtrace_line/1)

    %{
      type: type,
      message: message,
      backtrace: backtrace
    }
  end

  defp message?(line) do
    !stacktrace?(line) && !exception_header?(line)
  end

  defp stacktrace?(line) do
    Regex.match?(@stacktrace_regex, line)
  end

  defp exception_header?(line) do
    Regex.match?(@exception_header_regex, line)
  end

  defp backtrace_line(line) do
    hash = Regex.named_captures(@stacktrace_regex, line)
    {line, _} = Integer.parse(hash["line"])
    %{hash | "line" => line}
  end
end
