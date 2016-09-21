defmodule Aprb.Repo.Migrations.AddSummariesTable do
  use Ecto.Migration

  def change do
    create table(:summaries) do
      add :verb, :string
      add :summary_date, :date
      add :total_count, :integer, default: 0
      add :topic_id, :integer
      timestamps
    end
  end
end
