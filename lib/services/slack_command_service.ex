defmodule Aprb.Service.SlackCommandService do
  alias Aprb.{Repo,Subscriber,Topic,Subscription,Summary}
  import Ecto.Query

  def process_command(params) do
    subscriber = case Repo.get_by(Subscriber, channel_id: params[:channel_id]) do
        nil ->
          # create new subscriber
          sub_changeset = Subscriber.changeset(%Subscriber{}, Map.take(params, [:team_id, :team_domain, :channel_id, :channel_name, :user_id, :user_name]))
          case Repo.insert(sub_changeset) do
            {:ok, new_subscriber} ->
              subscriber = new_subscriber
            {:error, _changeset} ->
              raise("Can't create subscriber")
          end
        existing_subscriber ->
          existing_subscriber
      end

    response = cond do
      params[:text] == "topics" ->
        Repo.all( from topics in Topic, select: topics.name)
          |> Enum.join(" ")

      params[:text] == "subscriptions" ->
        current_topics = Repo.preload(subscriber, :topics).topics
          |> Enum.map(fn(topic) -> topic.name end)
          |> Enum.join(" ")
        "Subscribed topics: #{current_topics}"

      Regex.match?( ~r/unsubscribe/ , params[:text])  ->
        [command | topic_names] = String.split(params[:text], ~r{\s}, parts: 2)
        # add subscriptions
        removed_topics = for topic_name <- List.first(topic_names) |> String.split(~r{\s}) do
          topic = Repo.get_by(Topic, name: topic_name)
          if topic do
            subscription = Repo.get_by(Subscription, subscriber_id: subscriber.id, topic_id: topic.id)
            if subscription do
              Repo.delete(subscription)
              topic_name
            end
          end            
        end
        # remove nil from list
        removed_topics = Enum.reject(removed_topics, fn(x) -> x == nil end)
        if Enum.count(removed_topics) > 0 do
          ":+1: Unsubscribed from #{Enum.join(Enum.map(removed_topics, fn(x) -> "_#{x}_" end), " ")}"
        else
          "Can't find a matching subscription to unsubscribe!"
        end

      Regex.match?( ~r/subscribe/ , params[:text])  ->
        [command | topic_names] = String.split(params[:text], ~r{\s}, parts: 2)
        # add subscriptions
        subscribed_topics = for topic_name <- List.first(topic_names) |> String.split(~r{\s}) do
          topic = Repo.get_by(Topic, name: topic_name)
          if topic do
            subscription = Ecto.build_assoc(subscriber, :subscriptions, topic_id: topic.id)
            Repo.insert!(subscription)
            topic_name
          end
        end
        ":+1: Subscribed to #{Enum.join(subscribed_topics, " ")}"

      Regex.match?( ~r/summary/, params[:text]) ->
        command_parts = String.split(params[:text], ~r{\s}) |> Enum.drop(1)
        if Enum.count(command_parts) > 0 do
          require IEx
          IEx.pry
          topic = Repo.get_by(Topic, name: Enum.at(command_parts, 0))
          date = if Enum.count(command_parts) > 1, do: Calendar.Date.Parse.iso8601(Enum.at(command_parts, 1)), else: Calendar.Date.today! "America/New_York"
          summaries = Repo.all(from s in Summary,
                               where: s.summary_date == ^date and s.topic_id == ^topic.id)
          summaries
            |> Enum.map(fn(s) -> "#{s.verb}: #{s.total_count}" end)
            |> Enum.join(" \r\n ")
        end

      true ->
        "Unknown command! Supported commands: topics, subscriptions, subscribe <list of topics>, unsubscribe <list of topics>"
    end

    %{ response_type: "in_channel", text: response }
  end
end
