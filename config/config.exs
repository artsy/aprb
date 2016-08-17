use Mix.Config

config :slack, api_token: System.get_env("SLACK_API_TOKEN")

import_config "#{Mix.env}.exs"
