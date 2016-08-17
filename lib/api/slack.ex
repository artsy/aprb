defmodule Aprb.Api.Slack do
  use Maru.Router

  namespace :slack do
    desc "receiving slash commands from slack"
    params do
      
    end
    post do
      IO.inspect params
    end
  end
end