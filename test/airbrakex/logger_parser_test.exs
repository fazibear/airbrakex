defmodule Airbrakex.LoggerParserTest do
  use ExUnit.Case

  test "should parse exception from logs" do
    exception = """
    an exception was raised:
      ** (Ecto.NoResultsError) expected at least one result but got none in query:

    from g in Test.Game,
      where: g.id == ^"d8fe9f04-8fda-4d8f-9473-67ba94dc9458"

            (ecto) lib/ecto/repo/queryable.ex:57: Ecto.Repo.Queryable.one!/4
            (test) web/channels/game_channel.ex:15: Test.GameChannel.join/3
            (phoenix) lib/phoenix/channel/server.ex:154: Phoenix.Channel.Server.init/1
            (stdlib) gen_server.erl:328: :gen_server.init_it/6
            (stdlib) proc_lib.erl:239: :proc_lib.init_p_do_apply/3
    """

    result = %{
      backtrace: [
        %{
          "file" => "(ecto) lib/ecto/repo/queryable.ex",
          "function" => " Ecto.Repo.Queryable.one!/4",
          "line" => 57
        },
        %{
          "file" => "(test) web/channels/game_channel.ex",
          "function" => " Test.GameChannel.join/3",
          "line" => 15
        },
        %{
          "file" => "(phoenix) lib/phoenix/channel/server.ex",
          "function" => " Phoenix.Channel.Server.init/1",
          "line" => 154
        },
        %{
          "file" => "(stdlib) gen_server.erl",
          "function" => " :gen_server.init_it/6",
          "line" => 328
        },
        %{
          "file" => "(stdlib) proc_lib.erl",
          "function" => " :proc_lib.init_p_do_apply/3",
          "line" => 239
        }
      ],
      message:
        " expected at least one result but got none in query:\n\nfrom g in Test.Game,\n  where: g.id == ^\"d8fe9f04-8fda-4d8f-9473-67ba94dc9458\"\n\n",
      type: "Ecto.NoResultsError"
    }

    assert Airbrakex.LoggerParser.parse(exception) == result
  end
end
