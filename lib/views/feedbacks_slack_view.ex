defmodule Aprb.Views.FeedbacksSlackView do

  def render(event) do
    %{
      text: "#{event["subject"]["display"]} #{event["verb"]} #{event["properties"]["message"]} from #{event["properties"]["url"]}",
    }
  end
end
