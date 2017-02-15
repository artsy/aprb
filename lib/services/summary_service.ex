defmodule Aprb.Service.SummaryService do
  alias Aprb.{Repo, Topic, Summary}
  import Ecto.Query

  def update_summary(topic, event) do
    current_date = Calendar.Date.today! "America/New_York"
    cond do
      Enum.member?(~w(subscriptions users inquiries purchases conversations radiation.messages), topic.name) ->
        handle_summary(topic, event["verb"], current_date)
      Enum.member?(~w(auctions bidding), topic.name) ->
        handle_summary(topic, event["type"], current_date)
    end
  end

  def get_summary_for_month(topic, verb, year, month) do
    {:ok, start_of_month} = Date.new(year, month, 1)
    {:ok, last_day_of_month} = Date.new(year, month, :calendar.last_day_of_the_month(year, month))
    Repo.one(from s in Summary,
             where: s.summary_date >= ^Ecto.Date.cast!(start_of_month),
             where: s.summary_date <= ^Ecto.Date.cast!(last_day_of_month),
             where: s.topic_id == ^topic.id,
             where: s.verb == ^verb,
             group_by: [s.topic_id, s.verb],
             select: sum(s.total_count))
  end

  defp handle_summary(t, verb, date) do
    summary_query = Summary.find_by_topic_verb_date(t.id, verb, date)
    if !Repo.one(summary_query) do
      changeset = Summary.changeset(%Summary{}, %{topic_id: t.id, verb: verb, summary_date: date, total_count: 0})
      Repo.insert!(changeset)
    end
    summary = Repo.one(summary_query)
    updated_summary = Summary.changeset(summary, %{total_count: summary.total_count + 1})
    Repo.update(updated_summary)
  end
end
