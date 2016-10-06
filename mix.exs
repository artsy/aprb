defmodule Aprb.Mixfile do
  use Mix.Project

  def project do
    [app: :aprb,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env)]
  end

  def application do
    [ mod: {Aprb, []},
      applications: [:logger, :maru, :kafka_ex, :slack, :postgrex, :ecto, :calendar]]
  end

  defp aliases do
    [test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test --no-start"]]
  end

  defp deps do
    [ {:maru, github: "falood/maru"},
      {:kafka_ex, "~> 0.5.0"},
      {:poison, "~> 2.0"},
      {:slack, "~> 0.7.0"},
      {:websocket_client, github: "jeremyong/websocket_client"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.0.0"},
      {:money, "~> 1.1.0"},
      {:calendar, "~> 0.16.1"},
      {:ex_machina, "~> 1.0", only: :test} ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
