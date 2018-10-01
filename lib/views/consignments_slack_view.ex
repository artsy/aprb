defmodule Aprb.Views.ConsignmentsSlackView do
  import Aprb.ViewHelper

  def render(event) do
    artist_data = fetch_artist(event["properties"]["artist_id"])
    %{
      text: ":sparkles: #{event["properties"]["title"]} #{event["verb"]} <#{fetch_images(event)}|image>",
      attachments: [%{
                      fields: [
                        %{
                          title: "Artist",
                          value: "#{artist_data[:name]}",
                          short: true
                        },
                        %{
                          title: "Year",
                          value: "#{event["properties"]["year"]}",
                          short: true
                        },
                        %{
                          title: "Category",
                          value: "#{event["properties"]["category"]}",
                          short: true
                        },
                        %{
                          title: "Medium",
                          value: "#{event["properties"]["medium"]}",
                          short: true
                        }
                      ],
                      "actions": [
                        %{
                          "type": "button",
                          "text": "Admin Link",
                          "url": consignments_admin_link(event["object"]["id"])
                        }
                      ]
                    }],
      unfurl_links: true
    }
  end

  defp fetch_artist(artist_id) do
    artist_response = Gravity.get!("/artists/#{artist_id}").body
    %{
      permalink: artist_response["_links"]["permalink"]["href"],
      name: artist_response["name"]
    }
  end

  defp fetch_images(event) do
    event["properties"]["image_urls"]
    |> List.first
    |> Map.get("thumbnail")
  end
end
