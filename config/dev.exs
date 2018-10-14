use Mix.Config

config :maru, Aprb.Api.Root,
  http: [port: 4000, ip: {0,0,0,0}]

config :aprb, Aprb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: "aprb_dev",
  hostname: "localhost",
  pool_size: 10
