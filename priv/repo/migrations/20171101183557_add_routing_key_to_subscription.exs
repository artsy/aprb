defmodule Aprb.Repo.Migrations.AddRoutingKeyToSubscription do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :routing_key, :string, default: "#"
    end
  end
end
