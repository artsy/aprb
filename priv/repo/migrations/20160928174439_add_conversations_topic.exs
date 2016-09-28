defmodule Aprb.Repo.Migrations.AddConversationsTopic do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}
  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "conversations"})
    Repo.insert!(changeset)
  end
end
