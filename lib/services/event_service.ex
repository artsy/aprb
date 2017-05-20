defmodule Aprb.Service.EventService do
  alias Aprb.{Repo, Topic, Service.SummaryService, SubscriptionHelper}

  def receive_event(event, topic) do
    processed_message = event
                         |> Poison.decode!
                         |> process_event(topic)
    # broadcast a message to a topic
    if processed_message != nil do
      for subscriber <- get_topic_subscribers(topic) do
        Slack.Web.Chat.post_message("##{subscriber.channel_name}", processed_message[:text], %{attachments: processed_message[:attachments], unfurl_links: processed_message[:unfurl_links], as_user: true})
      end
    end
  end

  def process_event(event, topic_name) do
    topic = Repo.get_by(Topic, name: topic_name)
    summary_task = Task.async(fn -> SummaryService.update_summary(topic, event) end)
    case topic.name do
      "users" ->
        Aprb.Views.UserSlackView.render(event)
      "subscriptions" ->
        # wait for summary task to finish first
        Task.await(summary_task)
        current_summary = SummaryService.get_summary_for_month(topic, SubscriptionHelper.parsed_verb(event), DateTime.utc_now.year, DateTime.utc_now.month)
        Aprb.Views.SubscriptionSlackView.render(event, current_summary)
      "inquiries" ->
        Aprb.Views.InquirySlackView.render(event)
      "purchases" ->
        Aprb.Views.PurchaseSlackView.render(event)
      "bidding" ->
        Aprb.Views.BiddingSlackView.render(event)
      "auctions" ->
        Aprb.Views.BiddingSlackView.render(event)
      "radiation.messages" ->
        Aprb.Views.RadiationMessageSlackView.render(event)
      "conversations" ->
        Aprb.Views.ConversationSlackView.render(event)
      "invoices" ->
        Aprb.Views.InvoiceSlackView.render(event)
    end
  end

  defp get_topic_subscribers(topic_name) do
    topic = Repo.get_by(Topic, name: topic_name)
              |> Repo.preload(:subscribers)
    topic.subscribers
  end
end
