defmodule Aprb.Repo.Migrations.AddCommerceTopics do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}

  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "commerce"})
    Repo.insert!(changeset)
  end
end
