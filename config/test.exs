use Mix.Config

config :maru, Aprb.Api.Root,
  test: true

config :aprb, Aprb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "aprb_test",
  hostname: "localhost",
  pool_size: 10
