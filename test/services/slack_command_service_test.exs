defmodule Aprb.Service.SlackCommandServiceTest do
  use ExUnit.Case, async: true
  import Aprb.Factory
  alias Aprb.{Repo, Service.SlackCommandService}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Aprb.Repo, { :shared, self() })
    :ok
  end

  test "process_command: summary" do
    insert(:subscriber, channel_id: "artists")
    topic = insert(:topic, name: "artworks")
    insert(:summary, topic: topic, verb: "created", total_count: 10)
    insert(:summary, topic: topic, verb: "sold", total_count: 5)
    insert(:summary, topic: insert(:topic), verb: "created", total_count: 20)
    params = %{channel_id: "artists", text: "summary artworks"}
    response = SlackCommandService.process_command(params)
    assert response[:response_type] == "in_channel"
    today = Calendar.Date.today! "America/New_York"
    assert response[:text] == ":chart_with_upwards_trend: Summaries for #{today}: \r\n *created*: 10 \r\n *sold*: 5"
  end
end
