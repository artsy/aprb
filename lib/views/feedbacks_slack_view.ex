defmodule Aprb.Views.FeedbacksSlackView do
  alias Aprb.Service.SentimentAnalysisService
  
  def prefix(event) do
    emoji = event["properties"]["message"]
      |>SentimentAnalysisService.sentiment_score
      |>SentimentAnalysisService.sentiment_face_emoji

      ":artsy-email: (#{emoji})"
  end

  def render(event) do
    %{
      text: "#{prefix(event)} #{event["properties"]["user_name"]} <#{event["properties"]["user_email"]}> #{event["verb"]} from #{event["properties"]["url"]}\n\n#{event["properties"]["message"]}",
      attachments: [],
      unfurl_links: false
    }
  end
end
