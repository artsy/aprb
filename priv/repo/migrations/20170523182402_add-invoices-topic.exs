defmodule :"Elixir.Aprb.Repo.Migrations.Add-invoices-topic" do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}

  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "invoices"})
    Repo.insert!(changeset)
    bidding_topic = Repo.get_by(Topic, name: "bidding")
    if bidding_topic != nil, do: Repo.delete_all bidding_topic
  end
end
