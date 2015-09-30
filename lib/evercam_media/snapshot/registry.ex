defmodule EvercamMedia.Snapshot.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(table, event_manager, cameras, opts \\ []) do
    IO.puts inspect cameras
    IO.puts "CAMERAS"
    GenServer.start_link(__MODULE__, {table, event_manager, cameras}, opts)
  end

  @doc """
  Looks up the camera pid for `name` stored in `table`.

  Returns `{:ok, pid}` if a camera exists, `:error` otherwise.
  """
  def lookup(table, name) do
    # 2. lookup now expects a table and looks directly into ETS.
    #    No request is sent to the server.
    case :ets.lookup(table, name) do
      [{^name, camera}] -> {:ok, camera}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a camera associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  ## Server callbacks

  def init({table, events, cameras}) do
    refs = :ets.foldl(fn {name, pid}, acc ->
      HashDict.put(acc, Process.monitor(pid), name)
    end, HashDict.new, table)

    {:ok, %{names: table, refs: refs, events: events, cameras: cameras}}
  end

  # 4. The previous handle_call callback for lookup was removed

  def handle_call({:create, name}, _from, state) do
    case lookup(state.names, name) do
      {:ok, pid} ->
        {:reply, pid, state} # Reply with pid
      :error ->
        {:ok, pid} = EvercamMedia.Snapshot.ClientSupervisor.start_camera(state.cameras)
        ref = Process.monitor(pid)
        refs = HashDict.put(state.refs, ref, name)
        :ets.insert(state.names, {name, pid})
        GenEvent.sync_notify(state.events, {:create, name, pid})
        {:reply, pid, %{state | refs: refs}} # Reply with pid
    end
  end


  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    # 6. Delete from the ETS table instead of the HashDict
    {name, refs} = HashDict.pop(state.refs, ref)
    :ets.delete(state.names, name)
    GenEvent.sync_notify(state.events, {:exit, name, pid})
    {:noreply, %{state | refs: refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
