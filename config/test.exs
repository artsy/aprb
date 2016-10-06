use Mix.Config

config :maru, Aprb.Api.Root,
  test: true

config :aprb, Aprb.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  adapter: Ecto.Adapters.Postgres,
  database: "aprb_test"
