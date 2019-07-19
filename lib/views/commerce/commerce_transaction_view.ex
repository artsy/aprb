defmodule Aprb.Views.CommerceTransactionSlackView do
  import Aprb.ViewHelper
  alias Aprb.Views.CommerceHelper

  def render(event, _routing_key) do
    seller = CommerceHelper.fetch_participant_info(event["properties"]["order"]["seller_id"], event["properties"]["order"]["seller_type"])
    buyer = CommerceHelper.fetch_participant_info(event["properties"]["order"]["buyer_id"], event["properties"]["order"]["buyer_type"])

    %{
      text: ":alert: <#{stripe_search_link(event["properties"]["order"]["id"])}|Failed transaction>",
      author_name: event["properties"]["order"]["code"],
      author_link: exchange_admin_link(event["properties"]["order"]["id"]),
      title: seller["name"],
      title_link: exchange_partner_orders_link(seller["_id"]),
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
          %{
            title: "Buyer",
            value: cleanup_name(buyer["name"]),
            short: true
          }
        ]
      }],
      unfurl_links: true
    }
  end
end
