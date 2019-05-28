defmodule Aprb.Views.BiddingSlackView do
  @gravity_api Application.get_env(:aprb, :gravity_api)

  import Aprb.ViewHelper

  def render(event) do
    artwork_data = fetch_sale_artwork(event["lotId"])
    %{
      text: ":gavel: #{event["type"]} on #{artwork_data[:permalink]}",
      attachments: [%{
                      fields: [
                        %{
                          title: "Amount",
                          value: format_price(event["amountCents"] / 100, artwork_data[:currency]),
                          short: true
                        },
                        %{
                          title: "Estimate",
                          value: format_price(artwork_data[:estimate_cents], artwork_data[:currency])
                        },
                        %{
                          title: "Low Estimate",
                          value: format_price(artwork_data[:low_estimate_cents], artwork_data[:currency]),
                          short: true
                        },
                        %{
                          title: "High Estimate",
                          value: format_price(artwork_data[:high_estimate_cents], artwork_data[:currency]),
                          short: true
                        },
                        %{
                          title: "Lot number",
                          value: artwork_data[:lot_number],
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

  @spec estimate_field_value(nil | bitstring() | integer()) :: nil | float()
  def estimate_field_value(nil), do: nil
  def estimate_field_value(value) when is_integer(value), do: value / 100
  def estimate_field_value(value) when is_bitstring(value), do: String.to_integer(value) / 100

  defp fetch_sale_artwork(lot_id) do
    sale_artwork_response = @gravity_api.get!("/sale_artworks/#{lot_id}").body
    IO.puts(sale_artwork_response["currency"])
    %{
      permalink: sale_artwork_response["_links"]["permalink"]["href"],
      lot_number: sale_artwork_response["lot_number"],
      currency: sale_artwork_response["currency"],
      estimate_cents: estimate_field_value(sale_artwork_response["estimate_cents"]),
      high_estimate_cents: estimate_field_value(sale_artwork_response["high_estimate_cents"]),
      low_estimate_cents: estimate_field_value(sale_artwork_response["low_estimate_cents"])
    }
  end
end
