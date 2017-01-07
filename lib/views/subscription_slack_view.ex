defmodule Aprb.Views.SubscriptionSlackView do
  import ViewHelper
  def render(event, current_summary) do
    %{
      text: "",
      attachments: "[{
                      \"title\": \":moneybag: #{event["properties"]["partner"]["name"]}'s subscription #{event["verb"]}\",
                      \"title_link\": \"#{admin_partners_link("subscriptions/#{event["object"]["id"]}")}\",
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
      unfurl_links: false
    }
  end
end