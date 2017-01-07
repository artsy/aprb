defmodule Aprb.Views.UserSlackView do
  import ViewHelper

  def render(event) do
    %{
      text: ":heart: #{cleanup_name(event["subject"]["display"])} #{event["verb"]} #{artist_link(event["properties"]["artist"]["id"])}",
      unfurl_links: true
    }
  end
end
