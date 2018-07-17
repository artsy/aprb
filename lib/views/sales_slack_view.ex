defmodule Aprb.Views.SalesSlackView do
  import Aprb.ViewHelper
  def render(event, routing_key) do
    case routing_key do
      "sale.started" ->
        %{
          text: ":gavel: :star: ted: <#{artsy_sale_link(event["properties"]["id"])}|#{event["properties"]["name"]}>",
          attachments: sale_attachments(event),
          unfurl_links: true
        }
      "sale.ended" ->
        %{
          text: ":gavel: :shaka: : ended: <#{artsy_sale_link(event["properties"]["id"])}|#{event["properties"]["name"]}>",
          attachments: sale_attachments(event),
          unfurl_links: true
        }
    end
  end

  defp sale_attachments(event) do
    [%{
      fields: [
        %{
          title: "Sale Code",
          value: event["properties"]["sale_code"],
          short: true
        },
        %{
          title: "Admin Link",
          value: ohm_sale_link(event["properties"]["id"]),
          short: true
        }
      ]
    }]
  end
end