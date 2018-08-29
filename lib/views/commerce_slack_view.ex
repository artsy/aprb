# https://github.com/artsy/exchange/blob/master/app/events/order_event.rb#L1

defmodule Aprb.Views.CommerceSlackView do
  import Aprb.ViewHelper

  def render(event, _routing_key) do
    text = case event["properties"]["state"] do
      "submitted" -> "🤞 Order Submitted"
      "approved" -> ":yes: Order Approved"
      "rejected" -> ":soshocked: Order Rejected"
      "seller_lapsed" -> ":hourglass: Seller Lapsed"
      "fulfilled" -> " :shipitmoveit: Order Fulfilled"
      _ -> nil
    end
    case text do
      nil -> nil
      text ->
        %{
          text: text,
          attachments: [%{
                          fields: [
                            %{
                              title: "Total Amount",
                              value: format_price(event["properties"]["items_total_cents"] / 100),
                              short: true
                            },
                            %{
                              title: "Buyer",
                              value: fetch_info(event["properties"]["buyer_id"], event["properties"]["buyer_type"])["name"],
                              short: true
                            },
                            %{
                              title: "Seller",
                              value: fetch_info(event["properties"]["seller_id"], event["properties"]["seller_type"])["name"],
                              short: true
                            },
                            %{
                              title: "Artworks",
                              value: artworks_links_from_line_items(event["properties"]["line_items"]),
                              short: false
                            },
                          ]
                        }],
          unfurl_links: true
        }
      end
  end

  defp fetch_info(id, type) do
    case type do
      "partner" -> Gravity.get!("/partners/#{id}").body
      "user" -> Gravity.get!("/users/#{id}").body
    end
  end

  defp artworks_links_from_line_items(line_items) do
    line_items
      |> Enum.map(fn(li) -> artwork_link(li["artwork_id"]) end)
      |> Enum.join(", ")
  end
end
