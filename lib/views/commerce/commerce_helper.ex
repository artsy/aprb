defmodule Aprb.Views.ComerceHelper do
  @gravity_api Application.get_env(:aprb, :gravity_api)

  def fetch_participant_info(id, "user"), do: @gravity_api.get!("/users/#{id}").body
  def fetch_participant_info(id, _), do: @gravity_api.get!("/v1/partner/#{id}").body


  def line_item_attachments(line_items) do
    line_items
      |> Enum.map(&line_item_attachment(&1))
  end

  def line_item_attachment(line_item) do
    artwork = @gravity_api.get!("/v1/artwork/#{line_item["artwork_id"]}").body
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