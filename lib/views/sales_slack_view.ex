defmodule Aprb.Views.SalesSlackView do
  @gravity_api Application.get_env(:aprb, :gravity_api)

  import Aprb.ViewHelper
  def render(event, routing_key) do
    sale = fetch_sale(event["properties"]["id"])
    case routing_key do
      "sale.started" ->
        %{
          text: ":gavel: :star: ted: <#{artsy_sale_link(event["properties"]["id"])}|#{event["properties"]["name"]}>",
          attachments: sale_attachments(event, sale),
          unfurl_links: true
        }
      "sale.ended" ->
        %{
          text: ":gavel: :shaka: : ended: <#{artsy_sale_link(event["properties"]["id"])}|#{event["properties"]["name"]}>",
          attachments: sale_attachments(event, sale),
          unfurl_links: true
        }
    end
  end

  defp sale_attachments(event, sale) do
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
        },
        %{
          title: "Sale Type",
          value: sale[:sale_type],
          short: true
        },
        %{
          title: "Eligible Lots",
          value: sale[:eligible_sale_artworks_count],
          short: true
        },
      ]
    }]
  end

  defp fetch_sale(sale_id) do
    sale_response = @gravity_api.get!("/v1/sale/#{sale_id}").body
    %{
      sale_type: sale_response["sale_type"],
      eligible_sale_artworks_count: sale_response["eligible_sale_artworks_count"],
    }
  end
end