# Airbrakex [![Package Version](https://img.shields.io/hexpm/v/airbrakex.svg)](https://hex.pm/packages/airbrakex) [![Code Climate](https://codeclimate.com/github/fazibear/airbrakex/badges/gpa.svg)](https://codeclimate.com/github/fazibear/airbrakex) [![Build Status](https://travis-ci.org/fazibear/airbrakex.svg?branch=master)](https://travis-ci.org/fazibear/airbrakex)
Elixir client for the [Airbrake](https://airbrake.io) service!

## Installation

Add Airbrakex as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [{:airbrakex, "~> 0.1.7"}]
end
```

If on Elixir 1.3 or lower you will need to add it to your applications.

```elixir
def application do
  [applications: [:airbrakex]]
end
```


Then run `mix deps.get` in your shell to fetch the dependencies.

### Configuration

It requires `project_key` and `project` parameters to be set
in your application environment, usually defined in your `config/config.exs`.
`logger_level` and `environment` are optional.

```elixir
config :airbrakex,
  project_key: "abcdef12345",
  project_id: 123456,
  logger_level: :error,
  environment: Mix.env
```

#### Advanced Configuration

If you want to use errbit instance, set custom url as `endpoint`.
If you connect through a proxy or need to pass other specific options to
`HTTPoison` you can use `http_options`, see https://hexdocs.pm/httpoison/HTTPoison.html#request/5
for a list of the available options.

```elixir
config :airbrakex,
  project_key: "abcdef12345",
  project_id: 123456,
  endpoint: "http://errbit.yourdomain.com",
  http_options: [ssl: [cacertfile: "/path/to/certfile.pem"]]
```

## Usage

```elixir
try do
  IO.inspect("test",[],"")
rescue
  exception -> Airbrakex.notify(exception)
end
```

### Logger Backend

There is a Logger backend to send logs to the Airbrake,
which could be configured as follows:

```elixir
config :logger,
  backends: [:console, Airbrakex.LoggerBackend]
```

### Plug

You can plug `Airbrakex.Plug` in your web application Plug stack to send all exception to Airbrake

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Airbrakex.Plug

  # ...
end
```

### Ignore

You can ignore certain types of errors by specifying `:ignore` config key:

```elixir
config :airbrakex,
  ...
  # List form
  ignore: [Phoenix.Router.NoRouteError]
  # OR
  # Function
  ignore: fn(error) ->
    cond do
      error.type == Phoenix.Router.NoRouteError -> true
      String.contains?(error.message, "Ecto.NoResultsError") -> true
      true -> false
    end
  end
```



## Thankx
 - [Airbrake Elixir](https://github.com/romul/airbrake-elixir)
 - [AirbrakePlug](https://github.com/romul/airbrake_plug)
 - [Rollbax](https://github.com/elixir-addicts/rollbax)

## Thank you!

[![Become Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bePatron?u=6912974)
