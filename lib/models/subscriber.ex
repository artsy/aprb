defmodule Aprb.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "subscribers" do
    field :team_id,      :string
    field :team_domain,  :string
    field :channel_id,   :string
    field :channel_name, :string
    field :user_id,      :string
    field :user_name,    :string

    has_many :subscriptions, Aprb.Subscription
    has_many :topics, through: [:subscriptions, :topic]

    timestamps
  end


  @required_fields ~w(team_id team_domain channel_id channel_name user_id user_name)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:channel_id)
  end
end