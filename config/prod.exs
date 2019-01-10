use Mix.Config

config :aprb, Aprb.Server,
  adapter: Plug.Cowboy,
  plug: Aprb.Api.Root,
  port: 4000,
  scheme: :http,
  bind_addr: "0.0.0.0"

config :aprb, Aprb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  pool_size: 10
