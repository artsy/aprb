defmodule Aprb.Mixfile do
  use Mix.Project

  def project do
    [app: :aprb,
     version: "0.1.0",
     elixir: "~> 1.6",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env)]
  end

  def application do
    [ mod: {Aprb, []},
      applications: [:logger, :maru, :amqp, :slack, :postgrex, :ecto, :calendar]]
  end

  defp aliases do
    [test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test --no-start"]]
  end

  defp deps do
      [{:amqp, "~> 1.0"},
      {:cowboy, "~> 2.1"},
      {:calendar, "~> 0.17.2"},
      {:ecto, "~> 2.0.0"},
      {:ex_machina, "~> 1.0", only: :test},
      {:jason, "~> 1.1"},
      {:money, "~> 1.1.0"},
      {:poison, "~> 3.1", override: true},
      {:postgrex, ">= 0.0.0"},
      {:ranch_proxy_protocol, "~> 2.0", override: true},
      {:sentient, git: "https://github.com/rdalin82/sentient.git"},
      {:slack, "~> 0.14.0"},
      {:maru, "~> 0.13"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
