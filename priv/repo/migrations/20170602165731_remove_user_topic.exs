defmodule Aprb.Repo.Migrations.RemoveUserTopic do
  use Ecto.Migration

  alias Aprb.{Repo,Topic}

  def change do
    users_topic = Repo.get_by(Topic, name: "users")
    if users_topic != nil, do: Repo.delete_all users_topic
  end
end
