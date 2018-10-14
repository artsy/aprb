defmodule Aprb.Api.Slack do
  use Aprb.Api.Server
  alias Aprb.Service.SlackCommandService

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
      json(conn, SlackCommandService.process_command(params))
    end
  end
end
