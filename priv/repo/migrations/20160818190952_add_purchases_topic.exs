defmodule Aprb.Repo.Migrations.AddPurchasesTopic do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}
  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "purchases"})
    Repo.insert!(changeset)
  end
end
