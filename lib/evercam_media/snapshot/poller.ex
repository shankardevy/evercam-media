defmodule EvercamMedia.Snapshot.Poller do
  @moduledoc """
  Provides functions and workers for getting snapshots from the camera

  Functions can be called from other places to get snapshots manually.
  """

  use GenServer
  alias EvercamMedia.Snapshot.CamClient

  ## Client API
  @doc """
  Start the Snapshot server for a given camera.

  """
  def start_link(camera, opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Get a snapshot from the camera server
  """
  def get_snapshot(cam_server) do
    GenServer.call(cam_server, :get_camera_snapshot)
  end

  @doc """
  Start a worker for the camera that takes snapshot in frequent interval
  as defined in the args passed to the camera server.

  """
  def start_worker(cam_server) do
    GenServer.call(cam_server, :start_camera_worker)
  end

  @doc """
  Stop a worker for the camera.
  """
  def stop_worker(cam_server) do
    GenServer.call(cam_server, :stop_camera_worker)
  end

  @doc """
  Get the process id of the camera worker if there is a worker started o
  """
  def get_worker_pid(cam_server) do
    GenServer.call(cam_server, :get_camera_worker)
  end


  @doc """
  """
  def get_config(cam_server) do
    GenServer.call(cam_server, :get_camera_config)
  end

  @doc """
  """
  def update_config(cam_server, config) do
    GenServer.call(cam_server, {:update_camera_config, config})
  end


  ## Server Callbacks

  @doc """
  Initialize the camera server
  """
  def init(args) do
    state = %{config: args}
    {:ok, state}
  end

  @doc """
  Server callback for getting snapshot
  """
  def handle_call(:get_camera_snapshot, _from, state) do
    {:ok, config} = get_state(:config, state)

    result = CamClient.fetch_snapshot(config)
    {:reply, result, state}
  end

  @doc """
  Server callback for starting camera worker
  """
  def handle_call(:start_camera_worker, _from, state) do
    {:reply, nil, state}
  end

  @doc """
  Server callback for stopping camera worker
  """
  def handle_call(:stop_camera_worker, _from, state) do
    {:reply, nil, state}
  end

  @doc """
  Server callback for getting camera worker
  """
  def handle_call(:get_camera_worker, _from, state) do
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
    {:reply, nil, state}
  end

  @doc """
  Gets camera config from the server state
  """
  defp get_state(:config, state) do
    Map.fetch(state, :config)
  end

end
