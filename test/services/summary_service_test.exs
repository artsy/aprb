defmodule Aprb.Service.SummaryServiceTest do
  use ExUnit.Case, async: true
  import Aprb.Factory
  alias Aprb.{Repo, Summary, Service.SummaryService}
  
  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, { :shared, self() })
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  test "update_summary: users" do
    topic = insert(:topic, name: "users")
    event = %{
               "subject" => %{"display" => "Best collector"},
               "verb" => "followed",
               "properties" => %{
                  "artist" => %{
                    "id" => "test-artist"
                  }
               }
             }
    assert Repo.aggregate(Summary, :count, :verb) == 0
    response = SummaryService.update_summary("users", event)
    assert Repo.aggregate(Summary, :count, :verb) == 1
    summary = Repo.one(Summary)
    assert summary.topic_id == topic.id
    assert summary.verb == "followed"
    assert summary.total_count == 1

    # sending event again will add total_count in summary
    SummaryService.update_summary("users", event)
    # we don't add a new summary
    assert Repo.aggregate(Summary, :count, :verb) == 1
    summary = Repo.one(Summary)
    assert summary.topic_id == topic.id
    assert summary.verb == "followed"
    assert summary.total_count == 2
  end
end
