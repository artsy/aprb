require IEx
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
          Repo.preload(subscriber, :topics).topics

        Regex.match?( ~r/unsubscribe/ , params[:text])  ->
          [command | topic_names] = String.split(params[:text], ~r{\s}, parts: 2)
          # add subscriptions
          for topic_name <- String.split(topic_names, ~r{\s}) do
            topic = Repo.get_by!(Topic, name: topic_name)
            Repo.delete(from s in Subscription,
              where: s.subscriber_id == ^subscriber.id and s.topic_id == ^topic.id)
          end
          "Unsubscribed #{topic_names}!"

        Regex.match?( ~r/subscribe/ , params[:text])  ->
          [command | topic_names] = String.split(params[:text], ~r{\s}, parts: 2)
          # add subscriptions
          for topic_name <- List.first(topic_names) |> String.split(~r{\s}) do
            topic = Repo.get_by!(Topic, name: topic_name)
            subscription = Ecto.build_assoc(subscriber, :subscriptions, topic_id: topic.id)
            Repo.insert!(subscription)
          end
          "Subscribed to #{topic_names}!"
        true ->
          "Unknown command! Supported commands: topics, subscriptions, subscribe <list of topics>, unsubscribe <list of topics>"
      end
      text(conn, response)
    end
  end
end
