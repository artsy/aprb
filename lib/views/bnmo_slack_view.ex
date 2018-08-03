defmodule Aprb.Views.BiddingSlackView do
  import Aprb.ViewHelper

  def render(event, routing_key) do
    %{
      text: ":gavel: #{event["type"]} on #{artwork_data[:permalink]}",
      attachments: [%{
                      fields: [
                        %{
                          title: "Amount",
                          value: "#{format_price(event["amountCents"] / 100)}",
                          short: true
                        },
                        %{
                          title: "Lot number",
                          value: "#{artwork_data[:lot_number]}",
                          short: true
                        },
                        %{
                          title: "Paddle number",
                          value: "#{event["bidder"]["paddleNumber"]}",
                          short: true
                        }
                      ]
                    }],
      unfurl_links: true
    }
  end

  defp fetch_sale_artwork(lot_id) do
    sale_artwork_response = Gravity.get!("/sale_artworks/#{lot_id}").body
    %{
      permalink: sale_artwork_response["_links"]["permalink"]["href"],
      lot_number: sale_artwork_response["lot_number"]
    }
  end

  defp artworks_links_from_line_items(line_items) do
    line_items
      |> Enum.map(fn(li) -> artwork_link(li["artwork_id"]) end)
      |> Enum.join(", ")
  end
end
