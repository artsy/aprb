use Mix.Config

config :maru, Aprb.Api.Root,
  test: true

config :aprb, Aprb.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  adapter: Ecto.Adapters.Postgres,
  # username: System.get_env("DB_USER"),
  # password: System.get_env("DB_PASSWORD"),
  database: "aprb_test",
  hostname: System.get_env("DB_HOST") || "localhost"

config :aprb,
  gravity_api: GravityMock
