defmodule Aprb.Repo.Migrations.AddFeedbacksTable do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}

  def change do
    changeset = Topic.changeset(%Topic{}, %{name: "feedbacks"})
    Repo.insert!(changeset)
  end
end
