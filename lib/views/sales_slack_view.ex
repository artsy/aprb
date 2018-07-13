defmodule Aprb.Views.SalesSlackView do
  import Aprb.ViewHelper
  def render(event, routing_key) do
    case routing_key do
      "sale.started" ->
        %{
          text: ":gavel: :star: ted: <#{sale_link(event["properties"]["id"])}|#{event["properties"]["name"]}>",
          attachments: sale_attachments(event),
          unfurl_links: false
        }
      "sale.ended" ->
        %{
          text: ":gavel: :shaka: : ended: <#{sale_link(event["properties"]["id"])}|#{event["properties"]["name"]}>",
          attachments: sale_attachments(event),
          unfurl_links: false
        }
    end
  end

  defp sale_attachments(event) do
    [%{
      fields: [
        %{
          title: "Sale Code",
          value: "#{event["properties"]["sale_code"]}",
          short: true
        },
        %{
          title: "Description",
          value: "#{event["properties"]["description"]}",
          short: false
        }
      ]
    }]
  end
end