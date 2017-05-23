defmodule Aprb.Views.InvoiceSlackView do
  import Aprb.ViewHelper

  def render(event) do
    require IEx
    IEx.pry
    partner_data = fetch_partner_data(event["properties"]["partner_id"])
    %{
      text: ":money_with_wings: Invoice #{event["object"]["display"]} #{event["verb"]}",
      attachments: "[{
                      \"fields\": [
                        {
                          \"title\": \"Total\",
                          \"value\": \"#{format_price(event["properties"]["total_cents"] / 100)}\",
                          \"short\": true
                        },
                        {
                          \"title\": \"Partner\",
                          \"value\": \"#{partner_data["name"]}\",
                          \"short\": true
                        }
                      ]
                    }]",
      unfurl_links: true
    }
  end

  defp fetch_partner_data(partner_id) do
    Gravity.get!("/partners/#{partner_id}").body
  end
end
