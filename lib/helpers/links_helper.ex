defmodule LinksHelper do
  def artwork_link_from_conversation_event(conversation_event) do
    "https://www.artsy.net/artwork/#{List.first(conversation_event["properties"]["items"])["item_id"]}"
  end
end