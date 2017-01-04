require Logger

defmodule Aprb.Service.EventService do
  alias Aprb.{Repo, Topic, Service.SummaryService}
  import LinksHelper

  def receive_event(event, topic) do
    processed_message = event
                         |> Poison.decode!
                         |> process_event(topic)
    # broadcast a message to a topic
    if processed_message != nil do
      for subscriber <- get_topic_subscribers(topic) do
        Logger.debug "Sending #{processed_message} to #{subscriber.channel_name}"
        Slack.Web.Chat.post_message("##{subscriber.channel_name}", processed_message[:text], %{attachments: processed_message[:attachments], unfurl_links: processed_message[:unfurl_links], as_user: true})
      end
    end
  end

  def process_event(event, topic_name) do
    topic = Repo.get_by(Topic, name: topic_name)
    summary_task = Task.async(fn -> SummaryService.update_summary(topic, event) end)
    case topic.name do
      "users" ->
        %{text: ":heart: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} https://www.artsy.net/artist/#{event["properties"]["artist"]["id"]}",
          unfurl_links: true }

      "subscriptions" ->
        # wait for summaryt ask to finish first
        Task.await(summary_task)
        current_summary = SummaryService.get_summary_for_month(topic, event["verb"], DateTime.utc_now.year, DateTime.utc_now.month)
        %{text: "",
          attachments: "[{
                          \"title\": \":moneybag: #{event["properties"]["partner"]["name"]}'s subscription #{event["verb"]}\",
                          \"title_link\": \"https://admin-partners.artsy.net/subscriptions/#{event["object"]["id"]}\",
                          \"fields\": [
                            {
                              \"title\": \"Outreach Admin\",
                              \"value\": \"#{event["properties"]["partner"]["outreach_admin"]}\",
                              \"short\": true
                            },
                            {
                              \"title\": \"Total this month\",
                              \"value\": \"#{current_summary}\",
                              \"short\": true
                            }
                          ]
                        }]",
          unfurl_links: false }

      "inquiries" ->
        %{text: ":shaka: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} on #{artwork_link(event["properties"]["inquireable"]["id"])}",
          attachments: "[{
                          \"fields\": [
                            {
                              \"title\": \"Professional Buyer?\",
                              \"value\": \"#{event["properties"]["inquirer"]["professional_buyer"]}\",
                              \"short\": true
                            },
                            {
                              \"title\": \"Confirmed Buyer?\",
                              \"value\": \"#{event["properties"]["inquirer"]["confirmed_buyer"]}\",
                              \"short\": true
                            },
                            {
                              \"title\": \"Message Snippet\",
                              \"value\": \"#{event["properties"]["initial_message_snippet"]}\",
                              \"short\": false
                            }
                          ]
                        }]",
          unfurl_links: true }

      "purchases" ->
        %{text: ":shake: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} #{artwork_link(event["properties"]["artwork"]["id"])}",
          attachments: "[{
                          \"fields\": [
                            {
                              \"title\": \"Price\",
                              \"value\": \"#{format_price(event["properties"]["sale_price"] || 0)}\",
                              \"short\": true
                            }
                          ]
                        }]",
          unfurl_links: true }
      "bidding" ->
        artwork_data = fetch_sale_artwork(event["lotId"])
        %{
          text: ":gavel: #{event["type"]} on #{artwork_data[:permalink]}",
          attachments: "[{
                          \"fields\": [
                            {
                              \"title\": \"Amount\",
                              \"value\": \"#{format_price((event["amountCents"] || 0) / 100)}\",
                              \"short\": true
                            },
                            {
                              \"title\": \"Lot number\",
                              \"value\": \"#{artwork_data[:lot_number]}\",
                              \"short\": true
                            },
                            {
                              \"title\": \"Paddle number\",
                              \"value\": \"#{event["bidder"]["paddleNumber"]}\",
                              \"short\": true
                            }
                          ]
                        }]",
          unfurl_links: true
         }
      "conversations" ->
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

  defp fetch_sale_artwork(lot_id) do
    sale_artwork_response = Gravity.get!("/sale_artworks/#{lot_id}").body
    %{
      permalink: sale_artwork_response["_links"]["permalink"]["href"],
      lot_number: sale_artwork_response["lot_number"]
    }
  end

  defp get_topic_subscribers(topic_name) do
    topic = Repo.get_by(Topic, name: topic_name)
              |> Repo.preload(:subscribers)
    topic.subscribers
  end

  defp cleanup_name(full_name) do
    full_name
      |> String.split
      |> List.first
  end

  defp format_price(price) do
    if price do
      Money.to_string(Money.new(round(price * 100), :USD), symbol: false)
    else
      "N/A"
    end
  end
end
