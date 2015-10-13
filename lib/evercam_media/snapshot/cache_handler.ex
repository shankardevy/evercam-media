defmodule EvercamMedia.Snapshot.CacheHandler do
  use GenEvent
  require Logger

  @moduledoc """
  Stores the snapshot in the cache using ConCache module.
  Also stores previous snapshot using separate key, as well as the last one.
  Both `last` and `previous` are necessary for the MotionDetection module
  """

  def handle_event({:got_snapshot, data}, state) do
    {camera_exid, timestamp, image} = data
    image_byte_size = byte_size image
    note = "Evercam Proxy"

    Logger.info "Inside EvercamMedia.Snapshot.CacheHandler -> handle_event"
    Logger.info "camera_exid=#{camera_exid}"
    Logger.info "timestamp=#{timestamp}"
    Logger.info "image_byte_size=#{image_byte_size}"
    ConCache.put(:cache, camera_exid, %{image: image, timestamp: timestamp, notes: note})

    camera_exid_last = "#{camera_exid}_last"
    camera_exid_previous = "#{camera_exid}_previous"

    result = ConCache.get(:cache, camera_exid_last)
    last_image = result[:image]
    last_timestamp = result[:timestamp]
    last_notes = result[:notes]

    case last_timestamp do
      nil ->
        value = %{image: image, timestamp: timestamp, notes: note}
        ttl = 0
        ConCache.put(:cache, camera_exid_last, %ConCache.Item{value: value, ttl: ttl})
      _   ->
        value_previous = %{image: last_image, timestamp: last_timestamp, notes: last_notes}
        ttl_previous = 0
        ConCache.put(:cache, camera_exid_previous, %ConCache.Item{value: value_previous, ttl: ttl_previous})

        value = %{image: image, timestamp: timestamp, notes: note}
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
