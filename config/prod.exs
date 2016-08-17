use Mix.Config

config :kafka_ex,
  brokers: [{"ip-10-0-0-49.ec2.internal", 9092}, {"ip-10-0-0-248.ec2.internal", 9092}],
  consumer_group: System.get_env("KAFKA_CONSUMER_GROUP") || "kafka_ex_2_local",
  disable_default_worker: false,
  sync_timeout: 1000 #Timeout used synchronous requests from kafka. Defaults to 1000ms.

config :aprb, ecto_repos: [Aprb.Repo]

config :maru, Aprb.Api.Root,
  http: [port: 4000]

config :aprb, Aprb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  pool_size: 10
