defmodule Aprb.Api.Root do
  use Maru.Router

  before do
    plug Plug.Logger
    plug Plug.Parsers,
      pass: ["*/*"],
      json_decoder: Elixir.Jason,
      parsers: [:urlencoded, :json, :multipart]
  end
  mount Aprb.Api.Ping
  mount Aprb.Api.Slack

  desc "Root endpoint get"
  get do
    text(conn, "Tune into APR!")
  end
end
