defmodule Aprb.Views.ComerceHelper do
  def fetch_participant_info(id, "user"), do: Gravity.get!("/users/#{id}").body
  def fetch_participant_info(id, _), do: Gravity.get!("/v1/partner/#{id}").body


  def line_item_attachments(line_items) do
    line_items
      |> Enum.map(&line_item_attachment(&1))
  end

  def line_item_attachment(line_item) do
    artwork = Gravity.get!("/v1/artwork/#{line_item["artwork_id"]}").body
    %{
      fields: [
        %{
          title: "Available Purchase Modes",
          value: cond do
                    artwork["ecommerce"] && artwork["offer"] -> "BNMO"
                    artwork["ecommerce"] -> "BN"
                    artwork["offer"] -> "MO"
                    true -> "!?"
                 end,
          short: true
        }
      ]
    }
  end
end