defmodule Aprb.Service.EventService do
  alias Aprb.{Repo, Topic}
  def receive_event(event, topic) do
    proccessed_message = process_event(event, topic)
    # broadcast a message to a topic
    for subscriber <- get_topic_subscribers(topic) do
      Slack.Web.Chat.post_message("##{subscriber.channel_name}", proccessed_message[:text], %{attachments: proccessed_message[:attachments], unfurl_links: proccessed_message[:unfurl_links]})
    end
  end

  defp process_event(event, topic) do
    event = Poison.decode!(event.value)
    case topic do
      "users" ->
        %{text: ":heart: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} #{event["properties"]["artist"]["name"]} \n 
                  https://www.artsy.net/artist/#{event["properties"]["artist"]["id"]}",
          unfurl_links: true}

      "subscriptions" ->
        %{text: "",
          attachments: "[{
                          \"title\": \":moneybag: Subscription #{event["verb"]}\",
                          \"title_link\": \"https://admin-partners.artsy.net/subscriptions/#{event["object"]["id"]}\",
                          \"fields\": [
                            {
                              \"title\": \"By\",
                              \"value\": \"#{cleanup_name(event["subject"]["display"])}\",
                              \"short\": true
                            },
                            {
                              \"title\": \"Partner\",
                              \"value\": \"#{event["properties"]["partner"]["name"]}\",
                              \"short\": true
                            }
                          ]
                        }]",
          unfurl_links: false }

      "inquiries" ->
        %{text: ":shaka: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} on https://www.artsy.net/artwork/#{event["properties"]["inquireable"]["id"]}",
          unfurl_links: true }

      "purchases" ->
        IO.inspect event
        %{text: ":shake: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} https://www.artsy.net/artwork/#{event["properties"]["artwork"]["id"]}",
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
    end
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
      Money.to_string(Money.new(round(price * 100), :USD))
    else
      "N/A"
    end
  end
end