defmodule Aprb.Api.Root do
  use Aprb.Api.Server

  before do
    plug Plug.Logger
    plug Plug.Parsers,
      pass: ["*/*"],
      json_decoder: Jason,
      parsers: [:urlencoded, :json, :multipart]
  end
  mount Aprb.Api.Ping
  mount Aprb.Api.Slack

  desc "Root endpoint get"
  get do
    text(conn, "Tune into APR!")
  end
end
