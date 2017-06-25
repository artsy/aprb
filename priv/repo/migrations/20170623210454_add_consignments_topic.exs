defmodule Aprb.Repo.Migrations.AddConsignmentsTopic do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}

  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "consignments"})
    Repo.insert!(changeset)
  end
end
