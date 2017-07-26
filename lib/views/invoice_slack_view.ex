defmodule Aprb.Views.InvoiceSlackView do
  import Aprb.ViewHelper

  def render(event, routing_key) do
    partner_data = fetch_partner_data(event["properties"]["partner_id"])
    cond do
      routing_key =~ "merchant_account" ->
        merchant_account_message(event, partner_data)
      true ->
        invoice_message(event, partner_data)
    end
  end

  defp fetch_partner_data(partner_id) do
    Gravity.get!("/partners/#{partner_id}").body
  end

  defp merchant_account_message(_event, partner_data) do
    %{
      text: ":party-parrot: #{partner_data["name"]} setup merchant account",
      attachments: [],
      unfurl_links: true
    }
  end

  defp invoice_message(event, partner_data) do
    %{
      text: ":money_with_wings: Invoice #{event["object"]["display"]}",
      attachments: [%{
                      fields: [
                        %{
                          title: "Artworks",
                          value: "#{artworks_display_from_artworkgroups(event["properties"]["artwork_groups"])}",
                          short: false
                        },
                        %{
                          title: "Total",
                          value: "#{format_price(event["properties"]["total_cents"] / 100)}",
                          short: true
                        },
                        %{
                          title: "Partner",
                          value: "#{partner_data["name"]}",
                          short: true
                        }
                      ]
                    }],
      unfurl_links: true
    }
  end
end
