defmodule Aprb.Api.SlackTest do
  use ExUnit.Case, async: true
  use Maru.Test, for: Aprb.Api.Slack
  alias Aprb.{Repo, Subscriber, Topic, Subscription}

  setup_all do
    System.put_env("SLACK_SLASH_COMMAND_TOKEN", "token")

    on_exit fn ->
      System.delete_env("SLACK_SLASH_COMMAND_TOKEN")
    end
    :ok
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, { :shared, self() })
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    Repo.insert(Topic.changeset(%Topic{}, %{name: "subscriptions"}))
    Repo.insert(Topic.changeset(%Topic{}, %{name: "users"}))
    Repo.insert(Topic.changeset(%Topic{}, %{name: "inquiries"}))
    :ok
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

  test "creates subscriber when receiving proper token" do
    opts = [
      parsers: [Plug.Parsers.JSON],
      pass: ["*/*"],
      json_decoder: Poison
    ]
    conn = build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> put_body_or_params(~s({
          "token":"token",
          "team_id":"T123456",
          "team_domain":"example",
          "channel_id":"C123456",
          "channel_name":"aprb",
          "user_id":"U123456",
          "user_name":"apr",
          "command":"apr",
          "text":"subscribe subscriptions users",
          "response_url":"https://slack.example.com"
        }))
      |> put_plug(Plug.Parsers, opts)
      |> post("/slack")
    assert Repo.one(Subscriber).channel_id == "C123456"
    subscriber = Repo.get_by(Subscriber, channel_id: "C123456")
    subscriber = Repo.preload(subscriber, :topics)
    assert(Enum.count(subscriber.topics)) == 1
    assert(List.first(subscriber.topics).name) == "subscriptions"
  end
end
