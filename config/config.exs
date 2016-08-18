use Mix.Config

config :slack, api_token: System.get_env("SLACK_API_TOKEN")
config :aprb, ecto_repos: [Aprb.Repo]

import_config "#{Mix.env}.exs"
