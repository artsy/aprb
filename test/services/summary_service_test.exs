defmodule Aprb.Service.SummaryServiceTest do
  use ExUnit.Case, async: true
  import Aprb.Factory
  alias Aprb.{Repo, Summary, Service.SummaryService}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Aprb.Repo, { :shared, self() })

    :ok
  end

  test "update_summary: inquiries" do
    topic = insert(:topic, name: "inquiries")
    event = %{
               "subject" => %{"display" => "Best collector"},
               "verb" => "inquired",
               "properties" => %{
                  "inquireable" => %{
                    "id" => "artwork_1"
                  },
                  "inquirer" => %{
                    "professional_buyer" => true,
                    "confirmed_buyer" => false
                  },
                  "initial_message_snippet" => "this is a test"
               }
             }
    assert Repo.aggregate(Summary, :count, :verb) == 0
    SummaryService.update_summary(topic, event)
    assert Repo.aggregate(Summary, :count, :verb) == 1
    summary = Repo.one(Summary)
    assert summary.topic_id == topic.id
    assert summary.verb == "inquired"
    assert summary.total_count == 1

    # sending event again will add total_count in summary
    SummaryService.update_summary(topic, event)
    # we don't add a new summary
    assert Repo.aggregate(Summary, :count, :verb) == 1
    summary = Repo.one(Summary)
    assert summary.topic_id == topic.id
    assert summary.verb == "inquired"
    assert summary.total_count == 2
  end
end
