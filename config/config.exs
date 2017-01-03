use Mix.Config

config :slack, api_token: System.get_env("SLACK_API_TOKEN")
config :aprb, ecto_repos: [Aprb.Repo]
config :aprb,
  gravity_api_url: System.get_env("GRAVITY_API_URL"),
  gravity_api_token: System.get_env("GRAVITY_API_TOKEN")
config :aprb, RabbitMQ,
  username: System.get_env("RABBITMQ_USER"),
  password: System.get_env("RABBITMQ_PASSWORD"),
  host: System.get_env("RABBITMQ_HOST"),
  virtual_host: System.get_env("RABBITMQ_VHOST"),
  heartbeat: 5


import_config "#{Mix.env}.exs"
