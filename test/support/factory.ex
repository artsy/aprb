defmodule Aprb.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Aprb.Repo

  def subscriber_factory do
    %Aprb.Subscriber{
      team_id: "team1",
      team_domain: "artsy.sexy",
      channel_id: "wnyc-id",
      channel_name: sequence("WNYC"),
      user_id: sequence("userid"),
      user_name: sequence("Dale Cooper")
    }
  end

  def topic_factory do
    %Aprb.Topic{
      name: sequence("subscriptions"),
    }
  end

  def subscription_factory do
    %Aprb.Subscription{
      subscriber: build(:subscriber),
      topic: build(:topic)
    }
  end

  def summary_factory do
    {:ok, date} = Ecto.Date.cast(Calendar.Date.today!("America/New_York"))
    %Aprb.Summary{
      topic: build(:topic),
      verb: "followed",
      summary_date: date,
      total_count: 0
    }
  end
end
