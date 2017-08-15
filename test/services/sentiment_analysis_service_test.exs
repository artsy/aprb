defmodule Aprb.Service.SentimentAnalysisServiceTest do
  use ExUnit.Case, async: true
  alias Aprb.{Repo, Service.SentimentAnalysisService}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Aprb.Repo, { :shared, self() })
    :ok
  end

  describe "SentimentAnalysisServiceTest.sentiment_face_emoji/1" do
    test "with a low score" do
      response = SentimentAnalysisService.sentiment_face_emoji(-5)
      assert response == ":frowning:"
    end

    test "with a neutral score" do
      response = SentimentAnalysisService.sentiment_face_emoji(0)
      assert response == ":neutral_face:"
    end

    test "with a high score" do
      response = SentimentAnalysisService.sentiment_face_emoji(5)
      assert response == ":simple_smile:"
    end
  end
end
