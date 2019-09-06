defmodule Aprb.Views.InquirySlackView do
  import Aprb.ViewHelper

  def render(event) do
    %{
      text: ":shaka: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} on #{artwork_link(event["properties"]["inquireable"]["id"])}",
      attachments: [%{
                      fields: [
                        %{
                          title: "Professional Buyer?",
                          value: event["properties"]["inquirer"]["professional_buyer"],
                          short: true
                        },
                        %{
                          title: "Confirmed Buyer?",
                          value: event["properties"]["inquirer"]["confirmed_buyer"],
                          short: true
                        },
                        %{
                          title: "Message Snippet",
                          value: event["properties"]["initial_message_snippet"],
                          short: false
                        }
                      ]
                    }],
      unfurl_links: true
    }
  end
end
