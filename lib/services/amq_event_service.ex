defmodule Aprb.Service.AmqEventService do
  use GenServer
  use AMQP

  alias Aprb.Service.EventService

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(topic) do
    rabbitmq_connect(topic)
  end

  defp rabbitmq_connect(topic) do
    case Connection.open(Application.get_env(:aprb, RabbitMQ)) do
      {:ok, conn} ->
        # Get notifications when the connection goes down
        Process.monitor(conn.pid)
        {:ok, chan} = Channel.open(conn)
        Basic.qos(chan, prefetch_count: 10)
        Exchange.topic(chan, topic, durable: true)
        queue_name = "aprb_#{topic}_queue"
        Queue.declare(chan, queue_name, durable: true)
        Queue.bind(chan, queue_name, topic, routing_key: "*")
        {:ok, _consumer_tag} = Basic.consume(chan, queue_name)
        {:ok, {chan, topic}}
      {:error, message} ->
        IO.inspect message
        # Reconnection loop
        :timer.sleep(10000)
        rabbitmq_connect(topic)
    end
  end

  # 2. Implement a callback to handle DOWN notifications from the system
  #    This callback should try to reconnect to the server

  def handle_info({:DOWN, _, :process, _pid, _reason}, {_chan, topic}) do
    {:ok, {chan, topic}} = rabbitmq_connect(topic)
    {:noreply, {chan, topic}}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, {chan, topic}) do
    {:noreply, {chan, topic}}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, {chan, topic}) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, {chan, topic}) do
    {:noreply, {chan, topic}}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, {chan, topic}) do
    spawn fn -> consume(chan, topic, tag, redelivered, payload) end
    {:noreply, {chan, topic}}
  end

  defp consume(channel, topic, tag, redelivered, payload) do
    try do
      Basic.ack channel, tag
      if acceptable_message?(payload), do: EventService.receive_event(payload, topic)
    rescue
      exception ->
        # Requeue unless it's a redelivered message.
        # This means we will retry consuming a message once in case of exception
        # before we give up and have it moved to the error queue
        Basic.reject channel, tag, requeue: not redelivered
        IO.puts "Error parsing #{payload}"
    end
  end

  defp acceptable_message?(message) do
    try do
      Poison.decode!(message)
        |> is_map
    rescue
      Poison.SyntaxError -> false
    end
  end
end