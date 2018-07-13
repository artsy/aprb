defmodule Aprb.Service.SummaryService do
  require Logger
  alias Aprb.{Repo, Summary, SubscriptionHelper}
  import Ecto.Query

  def update_summary(topic, event) do
    current_date = Calendar.Date.today! "America/New_York"
    cond do
      Enum.member?(~w(users inquiries purchases conversations radiation.messages invoices consignments feedbacks sales), topic.name) ->
        handle_summary(topic, event["verb"], current_date)
      Enum.member?(~w(subscriptions), topic.name) ->
        handle_summary(topic, SubscriptionHelper.parsed_verb(event), current_date)
      Enum.member?(~w(auctions), topic.name) ->
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

  defp handle_summary(topic, verb, date) do
    results = case Repo.one(from s in Summary, where: s.topic_id == ^topic.id, where: s.verb == ^verb, where: s.summary_date == ^date) do
      nil -> %Summary{topic_id: topic.id, verb: verb, summary_date: Ecto.Date.cast!(date)}
      summary -> summary
    end
    |> Summary.changeset(%{})
    |> Repo.insert_or_update

    case results do
      {:ok, summary} ->
        update_total(summary)
      {:error, changeset} ->
        Logger.warn "There was an error in insert or update summary, #{changeset.errors}"
    end
  end

  defp update_total(summary) do
    from(s in Summary, where: s.id == ^summary.id)
      |> Repo.update_all(inc: [total_count: 1])
  end
end
