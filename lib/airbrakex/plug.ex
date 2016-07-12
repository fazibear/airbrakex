defmodule Airbrakex.Plug do
  defmacro __using__(_env) do
    quote location: :keep do
      @before_compile Airbrakex.Plug
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            session = Map.get(conn.private, :plug_session)

            error = Airbrakex.ExceptionParser.parse(exception)
            if proceed?(Application.get_env(:airbrakex, :ignore), error) do
              Airbrakex.Notifier.notify(error, [params: conn.params, session: session])
            end

            reraise exception, System.stacktrace
        end
      end

      defp proceed?(ignore, _error) when is_nil(ignore), do: true
      defp proceed?(ignore, error) when is_function(ignore), do: !ignore.(error)
      defp proceed?(ignore, error) when is_list(ignore), do: !Enum.any?(ignore, fn(el) -> el == error.type end)
    end
  end



end
