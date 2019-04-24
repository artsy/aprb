defmodule Aprb.Views.CommerceTransactionSlackView do
  import Aprb.ViewHelper

  def render(event, _routing_key) do
    %{
      text: ":alert: Failed Transaction",
      attachments: [%{
        fields: [
          %{
            title: "Mode",
            value: event["properties"]["order"]["mode"],
            short: true
          },
          %{
            title: "Failure Code",
            value: event["properties"]["failure_code"],
            short: true
          },
          %{
            title: "Failure Message",
            value: event["properties"]["failure_message"],
            short: true
          },
          %{
            title: "Transaction Type",
            value: event["properties"]["transaction_type"],
            short: true
          },
        ] ,
        actions: [
          %{
            type: "button",
            text: "Admin Link",
            url: exchange_admin_link(event["properties"]["order"]["id"])
          }
        ]
      }],
      unfurl_links: true
    }
  end
end
