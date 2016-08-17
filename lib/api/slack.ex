defmodule Aprb.Api.Slack do
  use Maru.Router
  import Ecto.Query

  alias Aprb.{Repo, Topic, Subscriber}
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
          |> halt()
      end

      subscriber = case Repo.get_by(Subscriber, user_id: params[:user_id]) do
          nil ->
            # create new subscriber
            sub_changeset = Subscriber.changeset(%Subscriber{}, Map.take(params, [:team_id, :team_domain, :channel_id, :channel_name, :user_id, :user_name]))
            case Repo.insert(sub_changeset) do
              {:ok, new_subscriber} ->
                subscriber = new_subscriber
              {:error, _changeset} ->
                text(conn, %{ message: "Can't create user"})
            end
          existing_subscriber ->
            existing_subscriber
        end

      response = cond do
        params[:text] == "topics" ->
          Repo.all(
            from topics in Topic,
            select: topics.name)

        params[:text] == "subscriptions" ->
          Repo.preload(subscriber, :topics).topics

        Regex.match?( ~r/subscribe/ , params[:text])  ->
          # add subscriptions
          IO.inspect params[:text]
        true ->
          "Unknown command! Supported commands: list, my-subs, subscribe <list of topics>"
      end
      text(conn, %{ response: response })
    end
  end
end
