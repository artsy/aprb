defmodule Aprb.Api.Slack do
  use Maru.Router

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

      # TODO: check that token matches, that the POST comes from our slack integration
      # if System.get_env("SLACK_SLASH_COMMAND_TOKEN") != params["token"] ...

      IO.inspect params
      json(conn, %{ hello: :world })
    end
  end
end
