defmodule Aprb.Api.PingTest do
  use ExUnit.Case, async: true
  use Maru.Test, for: Aprb.Api.Ping

  test "/ping" do
    assert "{\"ping\":\"pong\"}" = get("/ping") |> text_response
  end
end
