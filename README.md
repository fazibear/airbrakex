# Airbrakex

Elixir client for the [Airbrake](http://airbrake.com) service!

## Installation

Add Airbrakex as a dependency to your `mix.exs` file:

```elixir
defp deps() do
  [{:airbrakex, "~> 0.0.2"}]
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
