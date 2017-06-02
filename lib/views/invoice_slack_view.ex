defmodule Aprb.Views.InvoiceSlackView do
  import Aprb.ViewHelper

  def render(event) do
    partner_data = fetch_partner_data(event["properties"]["partner_id"])
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

  defp fetch_partner_data(partner_id) do
    Gravity.get!("/partners/#{partner_id}").body
  end
end
