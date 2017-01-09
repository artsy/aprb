defmodule Aprb.Repo.Migrations.AddRadiationMessagesTopic do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}
  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "radiation.messages"})
    Repo.insert!(changeset)
  end
end
