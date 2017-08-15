defmodule Aprb.Views.FeedbacksSlackView do
  import Sentient

  def sentiment_score(message) do
    Sentient.analyze(message)
  end

  def sentiment_emoji(score) do
    case score do
      score when score >= 2 -> ":simple_smile:"
      score when score <= -2 -> ":frowning:"
      _ -> ":neutral_face:"
    end
  end

  def prefix(event) do
    ":artsy-email: (#{sentiment_emoji(sentiment_score(event["properties"]["message"]))})"
  end

  def render(event) do
    %{
      text: "#{prefix(event)} #{event["properties"]["user_name"]} <#{event["properties"]["user_email"]}> #{event["verb"]} from #{event["properties"]["url"]}\n\n#{event["properties"]["message"]}",
      attachments: [],
      unfurl_links: false
    }
  end
end
