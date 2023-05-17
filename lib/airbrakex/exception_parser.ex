defmodule Airbrakex.ExceptionParser do
  @moduledoc false

  def parse(exception, stacktrace \\ []) do
    %{
      type: exception.__struct__,
      message: Exception.message(exception),
      backtrace: stacktrace(stacktrace)
    }
  end

  defp stacktrace(stacktrace) do
    Enum.map(stacktrace, fn
      {module, function, args, params} ->
        file = Keyword.get(params, :file)
        line_number = Keyword.get(params, :line, 0)

        function = if file do
          "#{function}#{args(args)}"
        else
          "#{module}.#{function}#{args(args)}"
        end

        file_path = if file do
          "(#{module}) #{file}"
        else
          "unknown"
        end

        %{
          file: file_path,
          line: line_number,
          function: function
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
