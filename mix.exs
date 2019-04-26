defmodule Aprb.Mixfile do
  use Mix.Project

  def project do
    [app: :aprb,
     version: "0.2.0",
     elixir: "~> 1.8",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env)]
  end

  def application do
    [ mod: {Aprb, []},
      applications: [:logger, :amqp, :slack, :postgrex, :ecto, :calendar]]
  end

  defp aliases do
    [test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test --no-start --cover --color"]]
  end

  defp deps do
    [ {:maru, "~> 0.13"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:amqp, "~> 1.1", override: true},
      {:poison, "~> 3.1", override: true},
      {:slack, "~> 0.15.0"},
      {:postgrex, ">= 0.0.0", override: true},
      {:ecto, "~> 2.0"},
      {:money, "~> 1.1.0"},
      {:calendar, "~> 0.17.2"},
      {:ex_machina, "~> 1.0", only: :test},
      {:sentient, git: "https://github.com/rdalin82/sentient.git"} ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
