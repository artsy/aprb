defmodule Aprb.Summary do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  alias Aprb.{Summary}

  schema "summaries" do
    field :verb, :string
    field :summary_date, :date
    field :total_count, :integer
    belongs_to :topic, Aprb.Topic
    timestamps()
  end

  @required_fields ~w(topic_id verb summary_date)
  @optional_fields ~w(total_count)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:topic_id)
    |> unique_constraint(:topic_verb_date, name: :summaries_topic_verb_date_unique_index)
  end

  def find_by_topic_verb_date(topic_id, verb, date) do
    from s in Summary,
    where: s.topic_id == ^topic_id and s.verb == ^verb and s.summary_date == ^date
  end
end
