defmodule Aprb.Api.SlackTest do
  use ExUnit.Case, async: true
  use Maru.Test, for: Aprb.Api.Slack

  setup do
    System.put_env("SLACK_SLASH_COMMAND_TOKEN", "token")

    on_exit fn ->
      System.delete_env("SLACK_SLASH_COMMAND_TOKEN")
    end
  end

  test "requires a token" do
    assert_raise Maru.Exceptions.InvalidFormatter, "Parsing Param Error: token", fn ->
      post("/slack")
    end
  end

  test "returns a 403 with an invalid token" do
    opts = [
      parsers: [Plug.Parsers.JSON],
      pass: ["*/*"],
      json_decoder: Poison
    ]

    # TODO: check status code

    assert_raise RuntimeError, "Unauthorized", fn -> build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> put_body_or_params(~s({
          "token":"invalid",
          "team_id":"T123456",
          "team_domain":"example",
          "channel_id":"C123456",
          "channel_name":"aprb",
          "user_id":"U123456",
          "user_name":"apr",
          "command":"subscribe",
          "text":"inquiries",
          "response_url":"https://slack.example.com"
        }))
      |> put_plug(Plug.Parsers, opts)
      |> post("/slack")
    end
  end
end
