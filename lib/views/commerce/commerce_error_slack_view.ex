# https://github.com/artsy/exchange/blob/master/app/events/application_error_event.rb

defmodule Aprb.Views.CommerceErrorSlackView do
  def render(event, _routing_key) do
    %{
      text: ":alert: Failed submitting an order",
      attachments: [%{
        fields: [
          %{
            title: "Type",
            value: event["properties"]["type"],
            short: true
          },
          %{
            title: "Code",
            value: event["properties"]["failure_message"],
            short: true
          },
        ] ++ data_fields(event["properties"]["data"]),
      }],
      unfurl_links: true
    }
  end

  defp data_fields(nil), do: []
  defp data_fields(data) do
    data
    |>Enum.map(fn({key, value}) ->
      %{
        title: key,
        value: value,
        short: true
      }
    end)
  end
end
