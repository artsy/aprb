use Mix.Config

config :slack, api_token: System.get_env("SLACK_API_TOKEN")
config :aprb, ecto_repos: [Aprb.Repo]
config :aprb,
  gravity_api_url: System.get_env("GRAVITY_API_URL"),
  gravity_api_token: System.get_env("GRAVITY_API_TOKEN")

import_config "#{Mix.env}.exs"
