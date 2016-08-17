defmodule Aprb.Api.Root do
  use Maru.Router

  before do
    plug Plug.Logger
    plug Plug.Parsers,
      pass: ["*/*"],
      json_decoder: Poison,
      parsers: [:urlencoded, :json, :multipart]
  end

  mount Aprb.Api.Slack
end
