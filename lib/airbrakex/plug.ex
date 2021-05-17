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
      defoverridable call: 2

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            session = Map.get(conn.private, :plug_session)

            error = ExceptionParser.parse(exception, __STACKTRACE__)

            _ =
              Notifier.notify(error,
                params: conn.params,
                session: session,
                context: %{url: Plug.Conn.request_url(conn)}
              )

            reraise exception, __STACKTRACE__
        end
      end
    end
  end
end
