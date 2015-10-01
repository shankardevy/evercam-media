defmodule EvercamMedia.Snapshot.Worker do
  @moduledoc """
  Provides functions and workers for getting snapshots from the camera

  Functions can be called from other places to get snapshots manually.
  """

  use GenServer
  alias EvercamMedia.Snapshot.CamClient

  ################
  ## Client API ##
  ################

  @doc """
  Start the Snapshot server for a given camera.
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:name])
  end

  @doc """
  Restart the poller for the camera that takes snapshot in frequent interval
  as defined in the args passed to the camera server.
  """
  def start_poller(cam_server) do
    GenServer.call(cam_server, :restart_camera_poller)
  end

  @doc """
  Stop the poller for the camera.
  """
  def stop_poller(cam_server) do
    GenServer.call(cam_server, :stop_camera_poller)
  end

  @doc """
  Get the configuration of the camera worker.
  """
  def get_config(cam_server) do
    GenServer.call(cam_server, :get_camera_config)
  end

  @doc """
  Update the configuration of the camera worker
  """
  def update_config(cam_server, config) do
    GenServer.call(cam_server, {:update_camera_config, config})
  end

  @doc """
  Get a snapshot from the camera server
  """
  def get_snapshot(cam_server) do
    GenServer.call(cam_server, :get_camera_snapshot)
  end
  def get_snapshot(cam_server, {:poll, timestamp}) do
    GenServer.cast(cam_server, {:get_camera_snapshot, timestamp})
  end

  ######################
  ## Server Callbacks ##
  ######################

  @doc """
  Initialize the camera server
  """
  def init(args) do
    {:ok, event_manager} = GenEvent.start_link
    {:ok, poller} = EvercamMedia.Snapshot.Poller.start_link(args)
    add_handlers(event_manager, args[:event_handlers])
    args = Map.merge args, %{
      poller: poller,
      event_manager: event_manager
    }
    IO.puts inspect args
    {:ok, args}
  end

  @doc """
  Server callback for restarting camera poller
  """
  def handle_call(:restart_camera_poller, _from, state) do
    {:reply, nil, state}
  end

  @doc """
  Server callback for stopping camera poller
  """
  def handle_call(:stop_camera_poller, _from, state) do
    {:reply, nil, state}
  end

  @doc """
  Server callback for getting camera config
  """
  def handle_call(:get_camera_config, _from, state) do
    {:reply, get_state(:config, state), state}
  end

  @doc """
  Server callback for updating camera config
  """
  def handle_call({:update_camera_config, config}, _from, state) do
    {:ok, old_config} = get_state(:config, state)
    updated_config = Map.merge old_config, config
    state = Map.merge(state, %{config: updated_config})
    {:reply, nil, state}
  end

  @doc """
  Server callback for getting snapshot
  """
  def handle_call(:get_camera_snapshot, _from, state) do
    {:reply, _get_snapshot(state), state}
  end

  @doc """
  """
  def handle_cast({:get_camera_snapshot, timestamp}, state) do
    case _get_snapshot(state) do
      {:ok, image} ->
        data = {state.name, timestamp, image}
        GenEvent.sync_notify(state.event_manager, {:got_snapshot, data})
      {:error, error}->
        data = {state.name, timestamp, error}
        GenEvent.sync_notify(state.event_manager, {:snapshot_error, data})
    end
    {:noreply, state}
  end


  #####################
  # Private functions #
  #####################

  @doc """
  Add all the event managers
  """
  defp add_handlers(event_manager, event_handlers) do
    Enum.each(event_handlers, &GenEvent.add_mon_handler(event_manager, &1,[]))
  end

  @doc """
  Gets camera config from the server state
  """
  defp get_state(:config, state) do
    Map.get(state, :config)
  end

  defp _get_snapshot(state) do
    config = get_state(:config, state)
    CamClient.fetch_snapshot(config)
  end

end
