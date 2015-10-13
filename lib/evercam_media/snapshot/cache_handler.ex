defmodule EvercamMedia.Snapshot.CacheHandler do
  use GenEvent

  @moduledoc """
  TODO
  """

  def handle_event({:got_snapshot, data}, state) do
    {camera_exid, timestamp, image} = data
    ConCache.put(:cache, camera_exid, %{image: image, timestamp: timestamp, notes: "Evercam Proxy"})

    camera_exid_last = "#{camera_exid}_last"
    camera_exid_previous = "#{camera_exid}_previous"

    camera_exid_last_result = ConCache.get(:cache, camera_exid_last)

    case camera_exid_last_result do
      nil -> Logger.info "There is no results for camera_exid_last_result #{camera_exid}"
      _   ->
        Logger.info "Got some results in camera_exid_last_result #{camera_exid}"
        ConCache.put(:cache, camera_exid_previous, camera_exid_last_result)
    end

    ConCache.put(:cache, camera_exid_last, %{image: image, timestamp: timestamp, notes: "Evercam Proxy"})

    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

end
