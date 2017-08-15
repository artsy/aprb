defmodule Aprb.Views.FeedbacksSlackView do
  def render(event) do
    %{
      text: ":artsy-email: #{event["properties"]["user_name"]} <#{event["properties"]["user_email"]}> #{event["verb"]} from #{event["properties"]["url"]}\n\n#{event["properties"]["message"]}",
      attachments: [],
      unfurl_links: false
    }
  end
end
