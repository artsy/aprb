defmodule Aprb.Service.EventServiceTest do
  use ExUnit.Case, async: false
  import Aprb.Factory
  alias Aprb.{Repo, Service.EventService}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Aprb.Repo, { :shared, self() })
    :ok
  end

  test "process_event: users" do
    insert(:topic, name: "users")
    event = %{
               "subject" => %{"display" => "Best collector"},
               "verb" => "followed",
               "properties" => %{
                  "artist" => %{
                    "id" => "test-artist"
                  }
               }
             }
    response = EventService.process_event(event, "users")
    assert response[:text]  == ":heart: Best followed https://www.artsy.net/artist/test-artist"
    assert response[:unfurl_links]  == true
  end

  test "process_event: subscriptions" do
    topic = insert(:topic, name: "subscriptions")
    insert(:summary, summary_date: Ecto.Date.cast!(Calendar.Date.today!("America/New_York")), topic: topic, verb: "activated", total_count: 2)
    event = %{
               "subject" => %{"display" => "admin 1"},
               "object" => %{"id" => "1"},
               "verb" => "activated",
               "properties" => %{
                  "partner" => %{
                    "name" => "gallery 1",
                    "outreach_admin" => "tester admin",
                    "initial_subscription" => false
                  }
               }
             }
    response = EventService.process_event(event, "subscriptions")
    assert response[:text]  == ""
    assert response[:unfurl_links] == false
    assert String.contains?(response[:attachments], "\"value\": \"3\"") == true
    assert String.contains?(response[:attachments], ":moneybag: gallery 1's subscription activated") == true
    assert String.contains?(response[:attachments], "tester admin") == true
  end

  test "process_event: conversations" do
    event = %{
               "object" => %{"display" => "Conversation 1"},
               "subject" => %{"display" => "Collector 1"},
               "verb" => "buyer_outcome_set",
               "properties" => %{
                  "buyer_outcome" => "other",
                  "buyer_outcome_comment" => "never received response",
                  "inquiry_id" => "inq1",
                  "items" => [
                    %{
                      "item_type" => "Artwork",
                      "item_id" => "artwork-1"
                    }
                  ]
               }
             }
    response = EventService.process_event(event, "conversations")
    assert response[:text]  == ":phone: Collector 1 responded on https://www.artsy.net/artwork/artwork-1"
    assert response[:unfurl_links]  == true
    # ignores when outcome wasn't other
    event = %{
               "object" => %{"display" => "Collector 1"},
               "subject" => %{"display" => "Gallery 1"},
               "verb" => "buyer_outcome_set",
               "properties" => %{
                  "radiation_conversation_id" => "123",
                  "buyer_outcome" => "purchased",
                  "buyer_outcome_comment" => nil,
                  "inquiry_id" => "inq1"
               }
             }
    response = EventService.process_event(event, "conversations")
    assert response == nil
  end

  test "process_event: conversations - seller outcome" do
    event = %{
               "subject" => %{"display" => "Gallery 1"},
               "object" => %{"id" => "1"},
               "verb" => "seller_outcome_set",
               "properties" => %{
                  "from_id" => "collector1",
                  "from_name" => "Collector One",
                  "seller_outcome" => "dont_trust",
                  "seller_outcome_comment" => "I really dont",
                  "dismissed" => true,
                  "inquiry_id" => "inq1",
                  "radiation_conversation_id" => "rad1",
                  "items" => [%{
                      "item_type" => "Artwork",
                      "item_id" => "artwork-1"
                  }]
               }
             }
    response = EventService.process_event(event, "conversations")
    assert response[:text]  == ":-1: Gallery 1 dismissed Collector One inquiry on https://www.artsy.net/artwork/artwork-1"
    assert response[:unfurl_links] == true
    assert String.contains?(response[:attachments], "\"value\": \"dont_trust\"") == true
    assert String.contains?(response[:attachments], "\"value\": \"I really dont\"") == true
    assert String.contains?(response[:attachments], "\"value\": \"https://radiation.artsy.net/admin/accounts/2/conversations/rad1\"") == true
  end
end
