defmodule Aprb.Views.ConsignmentsSlackView do
  def render(event) do
    artist_data = fetch_artist(event["properties"]["artist_id"])
    %{
      text: ":sparkles: #{event["subject"]["display"]} #{event["verb"]} #{event["properties"]["title"]} by #{artist_data[:permalink]}",
      attachments: [%{
                      fields: [
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
end
