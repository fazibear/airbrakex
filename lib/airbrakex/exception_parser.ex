defmodule Airbrakex.ExceptionParser do
  @moduledoc false

  def parse(exception, stacktrace) do
    %{
      type: exception.__struct__,
      message: Exception.message(exception),
      backtrace: stacktrace(stacktrace)
    }
  end

  defp stacktrace(stacktrace) do
    Enum.map(stacktrace, fn
      {module, function, args, []} ->
        %{
          file: "unknown",
          line: 0,
          function: "#{module}.#{function}#{args(args)}"
        }

      {module, function, args, [file: file, line: line_number]} ->
        %{
          file: "(#{module}) #{List.to_string(file)}",
          line: line_number,
          function: "#{function}#{args(args)}"
        }
    end)
  end

  defp args(args) when is_integer(args) do
    "/#{args}"
  end

  defp args(args) when is_list(args) do
    "(#{
      args
      |> Enum.map(&inspect(&1))
      |> Enum.join(", ")
    })"
  end
end
