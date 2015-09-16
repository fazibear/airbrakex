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

            if logging_enabled? do
              Airbrakex.ExceptionParser.parse(exception)
              |> Airbrakex.Notifier.notify([params: conn.params, session: session])
            end

            reraise exception, System.stacktrace
        end
      end

      defp logging_enabled? do
        Enum.member?(Application.get_env(:airbrakex, :logging_enabled_environments), Mix.env)
      end
    end
  end
end
