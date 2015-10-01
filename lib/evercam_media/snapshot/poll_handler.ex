defmodule EvercamMedia.Snapshot.PollHandler do
  use GenEvent

  def handle_event({:update_camera_config, worker_state}, state) do
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

end
