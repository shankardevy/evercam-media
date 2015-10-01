defmodule EvercamMedia.Snapshot.CacheHandler do
  use GenEvent

  def handle_event({:got_snapshot, data}, state) do
    {camera_exid, timestamp, image} = data
    ConCache.put(:cache, camera_exid, %{image: image, timestamp: timestamp, notes: "Evercam Proxy"})
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

end
