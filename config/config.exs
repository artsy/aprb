# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :aprb, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:aprb, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :slack, api_token: System.get_env("SLACK_API_TOKEN")

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
  username: "postgres",
  password: "postgres",
  database: "aprb_dev",
  hostname: "localhost",
  pool_size: 10