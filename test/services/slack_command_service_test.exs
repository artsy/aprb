defmodule Aprb.Service.SlackCommandServiceTest do
  use ExUnit.Case, async: true
  import Aprb.Factory
  alias Aprb.{Repo, Summary, Service.SlackCommandService}
  
  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, { :shared, self() })
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  test "process_command: summary" do
    subscriber = insert(:subscriber, channel_id: "artists")
    topic = insert(:topic, name: "artworks")
    created_summary = insert(:summary, topic: topic, verb: "created", total_count: 10)
    sold_summary = insert(:summary, topic: topic, verb: "sold", total_count: 5)
    another_topic_summary = insert(:summary, topic: insert(:topic), verb: "created", total_count: 20)
    params = %{channel_id: "artists", text: "summary artworks"}
    response = SlackCommandService.process_command(params)
    assert response[:response_type] == "in_channel"
    today = Calendar.Date.today! "America/New_York"
    assert response[:text] == ":chart_with_upwards_trend: Summaries for #{today}: \r\n *created*: 10 \r\n *sold*: 5"
  end
end
