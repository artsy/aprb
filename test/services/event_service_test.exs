defmodule Aprb.Service.EventServiceTest do
  use ExUnit.Case, async: true
  import Aprb.Factory
  alias Aprb.{Repo, Summary, Service.EventService}
  
  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, { :shared, self() })
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  test "process_event: users" do
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
    response = EventService.process_event(event, "users")
    assert response[:text]  == ":heart: Best followed https://www.artsy.net/artist/test-artist"
    assert response[:unfurl_links]  == true
  end

  test "process_event: conversations" do
    topic = insert(:topic, name: "conversations")
    event = %{
               "object" => %{"display" => "Collector 1"},
               "subject" => %{"display" => "Gallery 1"},
               "verb" => "received",
               "properties" => %{
                  "radiation_conversation_id" => "123",
                  "buyer_outcome" => "other",
                  "buyer_outcome_comment" => "never received response",
                  "inquiry_id" => "inq1"
               }
             }
    response = EventService.process_event(event, "conversations")
    assert response[:text]  == ":phone: Collector 1 responded on https://radiation.artsy.net/accounts/2/conversations/123"
    assert response[:unfurl_links]  == false
  end

  test "process_event: conversations ignores non-other outcomes" do
    topic = insert(:topic, name: "conversations")
    event = %{
               "object" => %{"display" => "Collector 1"},
               "subject" => %{"display" => "Gallery 1"},
               "verb" => "received",
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
end
