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
            if proceed?(error) do
              Airbrakex.Notifier.notify(error, [params: conn.params, session: session])
            end

            reraise exception, System.stacktrace
        end
      end

      defp proceed?(error) do
        ignore = Application.get_env(:airbrakex, :ignore)
        cond do
          is_nil(ignore) -> true
          is_function(ignore) -> !ignore.(error)
          is_list(ignore) -> !Enum.any?(ignore, fn(el) -> el == error.type end)
          true -> true
        end
      end
    end
  end



end
