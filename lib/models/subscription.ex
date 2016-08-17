defmodule Aprb.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    belongs_to :topic, Aprb.Topic
    belongs_to :subscriber, Aprb.Subscriber

    timestamps
  end

  @required_fields ~w(topic_id subscriber_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:topic_id)
    |> foreign_key_constraint(:subscriber_id)
  end
end