defmodule Aprb.Api.Ping do
  use Aprb.Server

  namespace :ping do
    desc "Ping which returns pong."
    get do
      json(conn, %{ ping: :pong })
    end
  end
end
