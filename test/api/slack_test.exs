require IEx

defmodule Aprb.ApiTest do
  use ExUnit.Case, async: true
  use Maru.Test, for: Aprb.Api.Slack

  test "POST /slack" do
    # posting an invalid token fails with a 401
  end
end
