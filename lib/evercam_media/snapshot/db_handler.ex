defmodule EvercamMedia.Snapshot.DBHandler do
  @doc """
  This module should ideally delegate all the updates to be made to the database
  on various events to another module.

  Right now, this is a extracted and slightly modified from the previous version of
  worker.

  These are the list of tasks for the db handler
    * Create an entry in the snapshots table for each retrived snapshots
    * Update the CameraActivity table whenever there is a change in the camera status
    * Update the status and last_polled_at values of Camera table
    * Update the thumbnail_url of the Camera table - This was done in the previous
    version and not now. This update can be avoided if thumbnails can be dynamically
    served.
  """
  use GenEvent
  require Logger
  alias EvercamMedia.Repo


  def handle_event({:got_snapshot, data}, state) do
    {camera_exid, timestamp, image} = data
    timestamp = Ecto.DateTime.utc
    spawn fn ->
      update_camera_status("#{camera_exid}", timestamp, true)
      |> save_snapshot_record(timestamp)
    end
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  def update_camera_status(camera_exid, timestamp, status) do
    #TODO Improve the db queries here
    camera = Repo.one! Camera.by_exid(camera_exid)
    camera_is_online = camera.is_online
    camera = construct_camera(camera, timestamp, status, camera_is_online == status)
    Repo.update camera
    #
    # unless camera_is_online == status do
    #   try do
    #     log_camera_status(camera.id, status, timestamp)
    #   rescue
    #     _error ->
    #       error_handler(_error)
    #   end
    #   Exq.Enqueuer.enqueue(
    #     :exq_enqueuer,
    #     "cache",
    #     "Evercam::CacheInvalidationWorker",
    #     camera_exid
    #   )
    # end
    camera
  end


  def log_camera_status(camera_id, true, timestamp) do
    Repo.insert %CameraActivity{camera_id: camera_id, action: "online", done_at: timestamp}
  end

  def log_camera_status(camera_id, false, timestamp) do
    Repo.insert %CameraActivity{camera_id: camera_id, action: "offline", done_at: timestamp}
  end

  defp save_snapshot_record(camera, timestamp) do
    Repo.insert %Snapshot{camera_id: camera.id, data: "S3", notes: "Evercam Proxy", created_at: timestamp}
  end

  defp construct_camera(camera, timestamp, _, true) do
    %{camera | last_polled_at: timestamp}
  end

  defp construct_camera(camera, timestamp, false, false) do
    %{camera | last_polled_at: timestamp, is_online: false}
  end

  defp construct_camera(camera, timestamp, true, false) do
    %{camera | last_polled_at: timestamp, is_online: true, last_online_at: timestamp}
  end

  defp error_handler(error) do
    Logger.error inspect(error)
    Logger.error Exception.format_stacktrace System.stacktrace
  end
end
