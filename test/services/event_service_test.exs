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
end
