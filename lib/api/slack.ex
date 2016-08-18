defmodule Aprb.Api.Slack do
  use Maru.Router
  import Ecto.Query

  alias Aprb.{Repo, Topic, Subscriber, Subscription}
  namespace :slack do
    desc "Process slash commands from Slack."
    params do
      requires :token, type: String
      requires :team_id, type: String
      requires :team_domain, type: String
      requires :channel_id, type: String
      requires :channel_name, type: String
      requires :user_id, type: String
      requires :user_name, type: String
      requires :command, type: String
      requires :text, type: String
      requires :response_url, type: String
    end
    post do
      # check that token matches, that the POST comes from our slack integration
      if System.get_env("SLACK_SLASH_COMMAND_TOKEN") != params[:token] do
        conn
          |> put_status(403)
          |> text("Unauthorized")

        raise("Unauthorized")
      end

      subscriber = case Repo.get_by(Subscriber, channel_id: params[:channel_id]) do
          nil ->
            # create new subscriber
            sub_changeset = Subscriber.changeset(%Subscriber{}, Map.take(params, [:team_id, :team_domain, :channel_id, :channel_name, :user_id, :user_name]))
            case Repo.insert(sub_changeset) do
              {:ok, new_subscriber} ->
                subscriber = new_subscriber
              {:error, _changeset} ->
                text(conn, "Can't create subscriber")
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
          ":+1: Unsubscribed from #{Enum.join(removed_topics, " ")}"

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
        true ->
          "Unknown command! Supported commands: topics, subscriptions, subscribe <list of topics>, unsubscribe <list of topics>"
      end
      text(conn, response)
    end
  end
end
