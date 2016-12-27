defmodule Aprb.EventReceiver do
  alias Aprb.Service.EventService

  def start_link(channel) do
    KafkaEx.create_worker(String.to_atom(channel))
    for message <- KafkaEx.stream(channel, 0, worker_name: String.to_atom(channel), offset: latest_offset(channel)), acceptable_message?(message.value) do
      EventService.receive_event(message.value, channel)
    end
  end

  defp latest_offset(channel) do
    KafkaEx.latest_offset(channel, 0)
        |> List.first
        |> Map.get(:partition_offsets)
        |> List.first
        |> Map.get(:offset)
        |> List.first
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