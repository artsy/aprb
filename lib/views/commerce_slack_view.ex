defmodule Aprb.Views.CommerceSlackView do
  import Aprb.ViewHelper

  def render(event, routing_key) do
    text = case event["properties"]["state"] do
      "submitted" -> "🤞 Order Submitted"
      "approved" -> ":yes: Order Approved"
      "rejected" -> ":soshocked: Order Rejected"
      "seller_lapsed" -> ":hourglass: Seller Lapsed"
      "fulfilled" -> " :shipitmoveit: Order Fulfilled"
    end
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
                          title: "Partner",
                          value: partner_data["name"],
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

  defp fetch_partner(partner_id) do
    Gravity.get!("/partners/#{partner_id}").body
  end

  defp artworks_links_from_line_items(line_items) do
    line_items
      |> Enum.map(fn(li) -> artwork_link(li["artwork_id"]) end)
      |> Enum.join(", ")
  end
end
