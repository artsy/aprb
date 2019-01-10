defmodule Aprb.Api.Root do
  use Aprb.Server

  before do
    plug Plug.Logger
    plug Plug.Parsers,
      pass: ["*/*"],
      json_decoder: Poison,
      parsers: [:urlencoded, :json, :multipart]
  end
  mount Aprb.Api.Ping
  mount Aprb.Api.Slack

  rescue_from Aprb.Api.Errors.Unauthorized, as: e do
    conn
    |> put_status(401)
    |> text("Unauthorized")
  end

  rescue_from [MatchError, RuntimeError], with: :custom_error

  rescue_from :all, as: e do
    conn
    |> put_status(Plug.Exception.status(e))
    |> text("Server Error")
  end

  defp custom_error(conn, exception) do
    IO.inspect(exception)
    conn
    |> put_status(500)
    |> text(exception.message)
  end

  desc "Root endpoint get"
  get do
    text(conn, "Tune into APR!")
  end
end
