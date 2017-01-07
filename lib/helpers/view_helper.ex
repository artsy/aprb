defmodule ViewHelper do
  def artwork_link(artwork_id) do
    "https://www.artsy.net/artwork/#{artwork_id}"
  end

  def artist_link(artist_id) do
    "https://www.artsy.net/artist/#{artist_id}"
  end

  def radiation_link(path) do
    "https://radiation.artsy.net/#{path}"
  end

  def admin_partners_link(path) do
    "https://admin-partners.artsy.net/#{path}"
  end

  def cleanup_name(full_name) do
    full_name
      |> String.split
      |> List.first
  end

  def format_price(price) do
    if price do
      Money.to_string(Money.new(round(price * 100), :USD), symbol: false)
    else
      "N/A"
    end
  end
end