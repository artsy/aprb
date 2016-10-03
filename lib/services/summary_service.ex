defmodule Aprb.Service.SummaryService do
  alias Aprb.{Repo, Topic, Summary}

  def update_summary(topic, event) do
    current_date = Calendar.Date.today! "America/New_York"
    cond do
      Enum.member?(~w(subscriptions users inquiries purchases conversations), topic) ->
        handle_summary(topic, event["verb"], current_date)
      topic == "bidding" ->
        handle_summary(topic, event["type"], current_date)
    end
  end

  defp handle_summary(topic_name, verb, date) do
    t = Repo.get_by!(Topic, name: topic_name)
    summary_query = Summary.find_by_topic_verb_date(t.id, verb, date)
    if !Repo.one(summary_query) do
      changeset = Summary.changeset(%Summary{}, %{topic_id: t.id, verb: verb, summary_date: date, total_count: 0})
      Repo.insert!(changeset)
    end
    summary = Repo.one(summary_query)
    updated_summary = Summary.changeset(summary, %{total_count: summary.total_count + 1})
    Repo.update(updated_summary)
  end

  defp handle_monthly(topic_name, verb, date) do
    t = Repo.get_by!(Topic, name: topic_name)
    monthly_query = Summary.find_by_topic_verb_month(t.id, verb, date)
    if !Repo.one(monthly_query) do
      changeset = Summary.changeset(%Summary{}, %{topic_id: t.id, verb: verb, summary_date: date, total_count: 0})
      Repo.insert!(changeset)
    end
    monthly = Repo.one(monthly_query)
    updated_monthly = Summary.changeset(monthly, %{total_count: monthly.total_count + 1})
    Repo.update(updated_monthly)
  end
end
