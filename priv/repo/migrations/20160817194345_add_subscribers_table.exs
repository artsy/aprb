defmodule Aprb.Repo.Migrations.AddSubscribersTable do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :team_id, :string
      add :team_domain, :string
      add :channel_id, :string
      add :channel_name, :string
      add :user_id, :string
      add :user_name, :string

      timestamps
    end

    create table(:topics) do
      add :name, :string

      timestamps
    end

    create table(:subscriptions) do
      add :subscriber_id, :integer
      add :topic_id, :integer
    end
  end
end
