defmodule Aprb.Views.SalesSlackView do
  @gravity_api Application.get_env(:aprb, :gravity_api)
  @sales_survey_link "https://docs.google.com/forms/d/e/1FAIpQLSeFjhuqrmTglW0K96GiwEjdEpxd3RuLk__LuNgoUfKbFgdNUg/viewform"

  import Aprb.ViewHelper
  def render(event, routing_key) do
    sale = fetch_sale(event["properties"]["id"])
    case routing_key do
      "sale.started" ->
        %{
          text: ":gavel: :star: ted: <#{artsy_sale_link(event["properties"]["id"])}|#{event["properties"]["name"]}>",
          attachments: sale_attachments(event, routing_key, sale),
          unfurl_links: true
        }
      "sale.ended" ->
        %{
          text: ":gavel: :shaka: : ended: <#{artsy_sale_link(event["properties"]["id"])}|#{event["properties"]["name"]}>",
          attachments: sale_attachments(event, routing_key, sale),
          unfurl_links: true
        }
    end
  end

  defp sale_attachments(event, routing_key, sale) do
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
      ],
      actions: actions(routing_key)
    }]
  end

  defp fetch_sale(sale_id) do
    sale_response = @gravity_api.get!("/v1/sale/#{sale_id}").body
    %{
      sale_type: sale_response["sale_type"],
      eligible_sale_artworks_count: sale_response["eligible_sale_artworks_count"],
    }
  end

  defp actions(routing_key) do
    case routing_key do
      "sale.ended" -> [%{
                        type: "button",
                        text: "Survey Link",
                        url: @sales_survey_link
                      }]
      _ -> []
    end
  end
end
