defmodule Airbrakex.Plug do
  @moduledoc """
  You can plug `Airbrakex.Plug` in your web application Plug stack
  to send all exception to `airbrake`

  ```elixir
  defmodule YourApp.Router do
    use Phoenix.Router
    use Airbrakex.Plug

    # ...
  end
  ```
  """

  alias Airbrakex.{ExceptionParser, Notifier}

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

            error = ExceptionParser.parse(exception)
            if proceed?(Application.get_env(:airbrakex, :ignore), error) do
              Notifier.notify(error, [params: conn.params, session: session])
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
