defmodule EvercamMedia.Snapshot.StatsHandler do
  use GenEvent

  @doc """
  Currently this module is just a placeholder.
  We could use this to populate stats such as
  * What is the request/response time for the last snapshot
  * What is the status of a camera
  * What is the history of response of a camera

  With these data stored, it would be possible to alter the camera worker
  based on the stats. For eg., if the camera consistently reponds with a delay of
  more than 1s, we modify the worker to NOT poll it for every second to get a snapshot even
  if the configuration of the camera says so.
  """
  def handle_event({:snapshot_error, data}, state) do
    # Handle stats
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

end
