# Airbrakex ![Package Version](https://img.shields.io/hexpm/v/airbrakex.svg)

Elixir client for the [Airbrake](http://airbrake.com) service!

## Installation

Add Airbrakex as a dependency to your `mix.exs` file:

```elixir
def application do
  [applications: [:airbrakex]]
end

defp deps do
  [{:airbrakex, "~> 0.0.4"}]
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
  backends: [Airbrakex.LoggerBackend]
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

## Thankx
 - [Airbrake Elixir](https://github.com/romul/airbrake-elixir)
 - [AirbrakePlug](https://github.com/romul/airbrake_plug)
 - [Rollbax](https://github.com/elixir-addicts/rollbax)
