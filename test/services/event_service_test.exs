defmodule Aprb.Service.EventServiceTest do
  use ExUnit.Case, async: false
  import Aprb.Factory
  alias Aprb.{Repo, Service.EventService}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Aprb.Repo, { :shared, self() })
    :ok
  end

  test "process_event: inquiries" do
    insert(:topic, name: "inquiries")
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
    response = EventService.process_event(event, "inquiries", "test_routing_key")
    assert response[:text]  == ":shaka: Best inquired on https://www.artsy.net/artwork/artwork_1"
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
    response = EventService.process_event(event, "subscriptions", "test_routing_key")
    assert response[:text]  == ""
    assert response[:unfurl_links] == false
    attachment = List.first(response[:attachments])
    assert attachment[:title] === ":moneybag: gallery 1's subscription activated"
    assert Enum.map(List.first(response[:attachments])[:fields], fn field -> %{field[:title] => field[:value]} end) === [%{"Outreach Admin" => "tester admin"}, %{"First Subscription?" => "false"}, %{"Total this month" => "3"}]
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
    response = EventService.process_event(event, "conversations", "test_routing_key")
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
    response = EventService.process_event(event, "conversations", "test_routing_key")
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
    response = EventService.process_event(event, "conversations", "test_routing_key")
    assert response[:text]  == ":-1: Gallery 1 dismissed Collector One inquiry on https://www.artsy.net/artwork/artwork-1"
    assert response[:unfurl_links] == true
    assert Enum.map(List.first(response[:attachments])[:fields], fn field -> %{String.to_atom(field[:title]) => field[:value]} end) === [%{Outcome: "dont_trust"}, %{Comment: "I really dont"}, %{Radiation: "https://radiation.artsy.net/admin/accounts/2/conversations/rad1"}]
  end

  describe "process_event: feedbacks" do
    test "with a logged in user" do
      event = %{
        "subject" => %{"display" => "User 1 <user@example.com>"},
        "object" => %{"id" => "1"},
        "verb" => "submitted",
        "properties" => %{
          "user_email" => "user@example.com",
          "user_name" => "User 1",
          "url" => "/user/delete",
          "message" => "Thanks"
        }
      }
      response = EventService.process_event(event, "feedbacks", "test_routing_key")
      assert response[:text]  == ":artsy-email: :simple_smile: User 1 <user@example.com> submitted from /user/delete\n\nThanks"
    end

    test "without a logged in user" do
      event = %{
        "subject" => nil,
        "object" => %{"id" => "1"},
        "verb" => "submitted",
        "properties" => %{
          "user_email" => "user@example.com",
          "user_name" => "User 1",
          "url" => "/user/delete",
          "message" => "Thanks"
        }
      }
      response = EventService.process_event(event, "feedbacks", "test_routing_key")
      assert response[:text]  == ":artsy-email: :simple_smile: User 1 <user@example.com> submitted from /user/delete\n\nThanks"
    end
  end
end
