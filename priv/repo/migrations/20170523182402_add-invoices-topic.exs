defmodule :"Elixir.Aprb.Repo.Migrations.Add-invoices-topic" do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}

  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "invoices"})
    Repo.insert!(changeset)
    bidding_topic = Repo.get_by!(Topic, name: "bidding")
    Repo.delete bidding_topic
  end
end
