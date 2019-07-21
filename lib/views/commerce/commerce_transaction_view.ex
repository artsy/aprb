defmodule Aprb.Views.CommerceTransactionSlackView do
  import Aprb.ViewHelper
  alias Aprb.Views.CommerceHelper

  def render(event, _routing_key) do
    seller = CommerceHelper.fetch_participant_info(event["properties"]["order"]["seller_id"], event["properties"]["order"]["seller_type"])
    buyer = CommerceHelper.fetch_participant_info(event["properties"]["order"]["buyer_id"], event["properties"]["order"]["buyer_type"])
    fields = basic_fields(event, buyer)
      |> append_seller_admin(seller)
    %{
      text: ":alert: <#{stripe_search_link(event["properties"]["order"]["id"])}|#{event["properties"]["failure_code"]}>",
      attachments: [%{
        color: "#6E1FFF",
        author_name: event["properties"]["order"]["code"],
        author_link: exchange_admin_link(event["properties"]["order"]["id"]),
        title: seller["name"],
        title_link: exchange_partner_orders_link(seller["_id"]),
        fields: fields
      }],
      unfurl_links: true
    }
  end

  defp basic_fields(event, buyer) do
    [
      %{
        title: "Purchase Method",
        value: event["properties"]["order"]["mode"],
        short: true
      },
      %{
        title: "Buyer",
        value: cleanup_name(buyer["name"]),
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
        title: "Total Amount",
        value: format_price(event["properties"]["order"]["items_total_cents"] / 100),
        short: true
      }
    ]
  end

  defp append_seller_admin(fields, %{"admin" => %{"name" => name}}), do: fields ++ [%{ title: "Admin", value: name, short: true}]
  defp append_seller_admin(fields, _), do: fields
end
