defmodule EvercamMedia.Snapshot.StatsHandler do
  use GenEvent

  def handle_event({:snapshot_error, data}, state) do
    # Handle stats
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

end
