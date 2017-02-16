defmodule Aprb do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Aprb.Repo, []),
      worker(Aprb.Service.AmqEventService, ["conversations"], id: :conversations),
      worker(Aprb.Service.AmqEventService, ["inquiries"], id: :amq_inquiries),
      worker(Aprb.Service.AmqEventService, ["radiation.messages"], id: :radiation_messages),
      worker(Aprb.Service.AmqEventService, ["subscriptions"], id: :subscriptions),
      worker(Aprb.Service.AmqEventService, ["auctions"], id: :auctions),
      worker(Aprb.Service.AmqEventService, ["purchases"], id: :purchases),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aprb.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
