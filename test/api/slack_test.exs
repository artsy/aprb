defmodule Aprb.Api.SlackTest do
  use ExUnit.Case, async: true
  use Maru.Test, for: Aprb.Api.Slack
  import Aprb.Factory
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
    :ok
  end

  def receive_slack_message(token, opts, text, channel_id) do
    build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> put_body_or_params(~s({
          "token": "#{token}",
          "team_id":"T123456",
          "team_domain":"example",
          "channel_id":"#{channel_id}",
          "channel_name":"aprb",
          "user_id":"U123456",
          "user_name":"apr",
          "command":"apr",
          "text": "#{text}",
          "response_url":"https://slack.example.com"
        }))
      |> put_plug(Plug.Parsers, opts)
      |> post("/slack")
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
    assert_raise RuntimeError, "Unauthorized", fn ->
      receive_slack_message("invalid", opts, "inquiries", "C123456")
    end
  end

  describe "subscribe" do
    test "subscribes to a topic when receiving subscribe command with proper token" do
      opts = [
        parsers: [Plug.Parsers.JSON],
        pass: ["*/*"],
        json_decoder: Poison
      ]
      topic1 = insert(:topic)
      conn = receive_slack_message("token", opts, "subscribe #{topic1.name} users", "C123456")
      assert conn.status == 200
      assert conn.resp_body == "{\"text\":\":+1: Subscribed to #{topic1.name} \",\"response_type\":\"in_channel\"}"
      assert Repo.one(Subscriber).channel_id == "C123456"
      subscriber = Repo.get_by(Subscriber, channel_id: "C123456")
      subscriber = Repo.preload(subscriber, :topics)
      assert(Enum.count(subscriber.topics)) == 1
      assert(List.first(subscriber.topics).name) == "subscriptions"
    end
  end

  describe "unsubscribe" do
    test "unsubscribes from a topic when receiving unsubscribe command with proper token" do
      opts = [
        parsers: [Plug.Parsers.JSON],
        pass: ["*/*"],
        json_decoder: Poison
      ]
      topic1 = insert(:topic)
      subscriber = insert(:subscriber)
      subscription = insert(:subscription, subscriber: subscriber, topic: topic1)
      conn = receive_slack_message("token", opts, "unsubscribe #{topic1.name} users", subscriber.channel_id)

      assert conn.status == 200
      assert conn.resp_body == "{\"text\":\":+1: Unsubscribed from _#{topic1.name}_\",\"response_type\":\"in_channel\"}"
      subscriber = Repo.get_by(Subscriber, channel_id: subscriber.channel_id)
      subscriber = Repo.preload(subscriber, :topics)
      assert(Enum.count(subscriber.topics)) == 0
    end

    test "returns proper message when receiving unsubscribe command for non-subscribed topic" do
      opts = [
        parsers: [Plug.Parsers.JSON],
        pass: ["*/*"],
        json_decoder: Poison
      ]
      topic1 = insert(:topic)
      subscriber = insert(:subscriber)
      subscription = insert(:subscription, subscriber: subscriber, topic: topic1)
      conn = receive_slack_message("token", opts, "unsubscribe random", subscriber.channel_id)

      assert conn.status == 200
      assert conn.resp_body == "{\"text\":\"Can't find a matching subscription to unsubscribe!\",\"response_type\":\"in_channel\"}"
      subscriber = Repo.get_by(Subscriber, channel_id: subscriber.channel_id)
      subscriber = Repo.preload(subscriber, :topics)
      assert(Enum.count(subscriber.topics)) == 0
    end
  end
end
