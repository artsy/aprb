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
  heartbeat: 5

config :maru, :json_library, Elixir.Jason

config :aprb, Aprb.Api.Server,
  adapter: Plug.Adapters.Cowboy2,
  plug: Aprb.Api.Root,
  http: [port: 4000, ip: {0,0,0,0}]

config :aprb,
  maru_servers: [Aprb.Api.Server]


import_config "#{Mix.env}.exs"
