defmodule Aprb.SubscriptionHelper do
  def parsed_verb(event) do
    initial = if event["properties"]["partner"]["initial_subscription"], do: 'initial', else: '' 
    "#{event["verb"]}-#{initial}"
  end
end
