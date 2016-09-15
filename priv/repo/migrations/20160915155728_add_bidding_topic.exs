defmodule Aprb.Repo.Migrations.AddBiddingTopic do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}
  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "bidding"})
    Repo.insert!(changeset)
  end
end
