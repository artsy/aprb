defmodule Aprb.Views.FeedbacksSlackView do
  alias Aprb.Service.SentimentAnalysisService

  def emoji(message) do
    message
      |> SentimentAnalysisService.sentiment_score
      |> SentimentAnalysisService.sentiment_face_emoji
  end

  def prefix(event) do
    message = event["properties"]["message"]
    ":artsy-email: #{emoji(message)}"
  end

  def render(event) do
    %{
      text: "#{prefix(event)} #{event["properties"]["user_name"]} <#{event["properties"]["user_email"]}> #{event["verb"]} from #{event["properties"]["url"]}\n\n#{event["properties"]["message"]}",
      attachments: [],
      unfurl_links: false
    }
  end
end
