defmodule EvercamMedia.Snapshot.CacheHandler do
  use GenEvent
  require Logger

  @moduledoc """
  TODO
  """

  def handle_event({:got_snapshot, data}, state) do
    {camera_exid, timestamp, image} = data
    image_byte_size = byte_size image
    Logger.info "Inside handle_event camera_exid=#{camera_exid} timestamp=#{timestamp} image_byte_size=#{image_byte_size}"
    ConCache.put(:cache, camera_exid, %{image: image, timestamp: timestamp, notes: "Evercam Proxy"})

    camera_exid_last = "#{camera_exid}_last"
    camera_exid_previous = "#{camera_exid}_previous"

    result = ConCache.get(:cache, camera_exid_last)
    last_image = result[:image]
    last_timestamp = result[:timestamp]
    last_notes = result[:notes]

    case last_timestamp do
      nil ->
        value = %{image: image, timestamp: timestamp, notes: "Evercam Proxy"}
        ttl = 0
        ConCache.put(:cache, camera_exid_last, %ConCache.Item{value: value, ttl: ttl})
      _   ->
        value_previous = %{image: last_image, timestamp: last_timestamp, notes: last_notes}
        ttl_previous = 0
        ConCache.put(:cache, camera_exid_previous, %ConCache.Item{value: value_previous, ttl: ttl_previous})

        value = %{image: image, timestamp: timestamp, notes: "Evercam Proxy"}
        ttl = 0
        ConCache.put(:cache, camera_exid_last, %ConCache.Item{value: value, ttl: ttl})
    end

    last = ConCache.get(:cache, camera_exid_last)
    previous = ConCache.get(:cache, camera_exid_previous)
    Logger.info "last = #{last[:timestamp]}, previous = #{previous[:timestamp]}"

    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

end
