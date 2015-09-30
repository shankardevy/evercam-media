defmodule EvercamMedia.Snapshot.ConfigServer do
  @moduledoc """
  Provides functions and workers for storing the configuration of the camera
  """

  use GenServer

  ## Client API
  @doc """
  Start the Snapshot server for a given camera.

  """
  def start_link(camera, opts \\ []) do
    camera = EvercamMedia.Repo.preload camera, :cloud_recordings
    url = "#{Camera.external_url(camera)}#{Camera.res_url(camera, "jpg")}"
    parsed_uri = URI.parse url
    auth = Camera.auth(camera)
    vendor_exid = Camera.get_vendor_exid_by_camera_exid(camera.exid)
    sleep = Camera.sleep(camera)
    initial_sleep = Camera.initial_sleep(camera)

    args = [
      camera_id: camera.id,
      camera_exid: camera.exid,
      vendor_exid: vendor_exid,
      schedule: Camera.schedule(camera),
      timezone: camera.timezone,
      url: url,
      auth: auth,
      sleep: sleep,
      initial_sleep: initial_sleep
    ]
    GenServer.start_link(__MODULE__, args, opts)
  end

  @doc """
  Get a snapshot from the camera server
  """
  def get_snapshot(cam_server) do
    GenServer.call(cam_server, :get_camera_snapshot)
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
    {:ok, args}
  end

  @doc """
  Server callback for getting camera config
  """
  def handle_call(:get_camera_config, _from, state) do
    {:reply, state, state}
  end

  @doc """
  Server callback for updating camera config
  """
  def handle_call({:update_camera_config, config}, _from, state) do
    {:reply, nil, state}
  end

end
