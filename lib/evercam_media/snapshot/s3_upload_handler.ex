defmodule EvercamMedia.Snapshot.S3UploadHandler do
  use GenEvent
  alias EvercamMedia.Snapshot.S3Upload
  require Logger

  def handle_event({:got_snapshot, data}, state) do
    {camera_exid, timestamp, image} = data
    spawn fn ->
      Logger.info "Uploading snapshot to S3 for camera #{camera_exid} taken at #{timestamp}"
      S3Upload.put(camera_exid, timestamp, image)
    end
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end
end
