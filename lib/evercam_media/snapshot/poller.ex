defmodule EvercamMedia.Snapshot.Poller do
  @moduledoc """
  Provides functions and workers for getting snapshots from the camera

  Functions can be called from other places to get snapshots manually.
  """

  use GenServer
  alias EvercamMedia.Snapshot.Worker
  import EvercamMedia.Schedule

  ################
  ## Client API ##
  ################

  @doc """
  Start a poller for camera worker.
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @doc """
  Restart the poller for the camera that takes snapshot in frequent interval
  as defined in the args passed to the camera server.
  """
  def start_timer(cam_server) do
    GenServer.call(cam_server, :restart_camera_timer)
  end

  @doc """
  Stop the poller for the camera.
  """
  def stop_timer(cam_server) do
    GenServer.call(cam_server, :stop_camera_timer)
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


  ######################
  ## Server Callbacks ##
  ######################

  @doc """
  Initialize the camera server
  """
  def init(args) do
    args = Map.merge args, %{
      timer: start_timer(args.config.sleep, :poll)
    }
    {:ok, args}
  end

  @doc """
  Server callback for restarting camera poller
  """
  def handle_call(:restart_camera_timer, _from, state) do
    {:reply, nil, state}
  end

  @doc """
  Server callback for stopping camera poller
  """
  def handle_call(:stop_camera_timer, _from, state) do
    {:reply, nil, state}
  end

  @doc """
  Server callback for polling
  """
  def handle_info(:poll, state) do
    {:ok, timer} = Map.fetch(state, :timer)
    :erlang.cancel_timer(timer)
    timestamp = Calendar.DateTime.now!("UTC") |> Calendar.DateTime.Format.unix
    if scheduled?(state.config.schedule, state.config.timezone) do
      Worker.get_snapshot(state.name, {:poll, timestamp})
    end    
    timer = start_timer(state.config.sleep, :poll)
    {:noreply, Map.put(state, :timer, timer)}
  end

  @doc """
  Take care of unknown messages which otherwise would trigger function clause mismatch error.
  """
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  #######################
  ## Private functions ##
  #######################

  defp start_timer(sleep, message) do
    :erlang.send_after(sleep, self(), message)
  end

end
