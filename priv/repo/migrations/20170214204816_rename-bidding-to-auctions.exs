defmodule :"Elixir.Aprb.Repo.Migrations.Rename-bidding-to-auctions" do
  use Ecto.Migration
  alias Aprb.{Repo,Topic}
  def change do
    bidding_topic = Repo.get_by!(Topic, name: "bidding")
    auction_topic = Topic.changeset(bidding_topic, %{name: "auctions"})
    Repo.update!(auction_topic)
  end
end
