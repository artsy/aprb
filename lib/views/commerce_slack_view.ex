# https://github.com/artsy/exchange/blob/master/app/events/order_event.rb#L1

defmodule Aprb.Views.CommerceSlackView do
  import Aprb.ViewHelper

  def render(event, _routing_key) do
    title = case event["properties"]["state"] do
      "submitted" -> "🤞 Submitted"
      "approved" -> ":yes: Approved"
      "rejected" -> ":soshocked: Rejected"
      "seller_lapsed" -> ":hourglass: Seller Lapsed"
      "refunded" -> ":sad-parrot: Refunded"
      "fulfilled" -> " :shipitmoveit: Fulfilled"
      _ -> nil
    end

    case title do
      nil -> nil
      title ->
        %{
          text: title,
          attachments: attachments(event),
          unfurl_links: true
        }
      end
  end

  defp attachments(event) do
    seller = fetch_info(event["properties"]["seller_id"], event["properties"]["seller_type"])
    buyer = fetch_info(event["properties"]["buyer_id"], event["properties"]["buyer_type"])
    fields =
      case seller["admin"] do
        nil -> attachment_fields(event, buyer, seller)
        admin -> attachment_fields(event, buyer, seller) ++ %{ title: "Admin", value: admin["name"], short: true}
      end
    [%{
      fields: fields,
      "actions": [
        %{
          "type": "button",
          "text": "Admin Link",
          "url": exchange_admin_link(event["object"]["id"])
        }
      ]
    }]
  end

  defp attachment_fields(event, buyer, seller) do
    [
      %{
        title: "Code",
        value: event["properties"]["code"],
        short: true
      },
      %{
        title: "Total Amount",
        value: format_price(event["properties"]["items_total_cents"] / 100),
        short: true
      },
      %{
        title: "Buyer",
        value: cleanup_name(buyer["name"]),
        short: true
      },
      %{
        title: "Seller",
        value: seller["name"],
        short: true
      },
      %{
        title: "Artworks",
        value: artworks_links_from_line_items(event["properties"]["line_items"]),
        short: false
      },
    ]
  end

  defp fetch_info(id, type) do
    case type do
      "user" -> Gravity.get!("/users/#{id}").body
      _ -> Gravity.get!("/v1/partner/#{id}").body
    end
  end

  defp artworks_links_from_line_items(line_items) do
    line_items
      |> Enum.map(fn(li) -> artwork_link(li["artwork_id"]) end)
      |> Enum.join(", ")
  end
end
