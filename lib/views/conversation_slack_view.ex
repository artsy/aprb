defmodule Aprb.Views.ConversationSlackView do
  import ViewHelper

  def render(event) do
    case event["verb"] do
      "buyer_outcome_set" ->
        if event["properties"]["buyer_outcome"] == "other" do
          %{
            text: ":phone: #{event["subject"]["display"]} responded on #{artwork_link(List.first(event["properties"]["conversation_items"])["item_id"])}",
            attachments: "[{
                            \"fields\": [
                              {
                                \"title\": \"Outcome\",
                                \"value\": \"#{event["properties"]["buyer_outcome"]}\",
                                \"short\": true
                              },
                              {
                                \"title\": \"Comment\",
                                \"value\": \"#{event["properties"]["buyer_outcome_comment"]}\",
                                \"short\": false
                              }
                            ]
                          }]",
            unfurl_links: true
          }
        end
      "seller_outcome_set" ->
        %{
          text: ":-1: #{event["subject"]["display"]} dismissed #{event["properties"]["from_name"]} inquiry on #{artwork_link(List.first(event["properties"]["items"])["item_id"])}",
          attachments: "[{
                          \"fields\": [
                            {
                              \"title\": \"Outcome\",
                              \"value\": \"#{event["properties"]["seller_outcome"]}\",
                              \"short\": true
                            },
                            {
                              \"title\": \"Comment\",
                              \"value\": \"#{event["properties"]["seller_outcome_comment"]}\",
                              \"short\": false
                            },
                            {
                              \"title\": \"Radiation\",
                              \"value\": \"https://radiation.artsy.net/admin/accounts/2/conversations/#{event["properties"]["radiation_conversation_id"]}\",
                              \"short\": false
                            }
                          ]
                        }]",
          unfurl_links: true
        }
    end
  end
end