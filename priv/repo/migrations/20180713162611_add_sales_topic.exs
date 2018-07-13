defmodule Aprb.Repo.Migrations.AddSalesTopic do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}

  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "sales"})
    Repo.insert!(changeset)
  end
end
