defmodule EvercamMedia.ONVIFPTZController do
  use Phoenix.Controller
  alias EvercamMedia.ONVIFPTZ
  require Logger

  def status(conn, %{"id" => id}) do
    [url, username, password] = Camera.get_camera_info id
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.get_status(url, username, password, profile)
    default_respond(conn, 200, response)
  end

  def nodes(conn, %{"id" => id}) do
    [url, username, password] = Camera.get_camera_info id
    {:ok, response} = ONVIFPTZ.get_nodes(url, username, password)
    default_respond(conn, 200, response)
  end

  def configurations(conn, %{"id" => id}) do
    [url, username, password] = Camera.get_camera_info id
    {:ok, response} = ONVIFPTZ.get_configurations(url, username, password)
    default_respond(conn, 200, response)
  end

  def presets(conn, %{"id" => id}) do
    [url, username, password] = Camera.get_camera_info id
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.get_presets(url, username, password, profile)
    default_respond(conn, 200, response)
  end

  def stop(conn, %{"id" => id}) do
    [url, username, password] = Camera.get_camera_info id
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.stop(url, username, password, profile)
    default_respond(conn, 200, response)
  end

  def home(conn, %{"id" => id}) do
    [url, username, password] = Camera.get_camera_info id
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.goto_home_position(url, username, password, profile)
    default_respond(conn, 200, response)
  end

  def sethome(conn, %{"id" => id}) do
    [url, username, password] = Camera.get_camera_info id
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.set_home_position(url, username, password, profile)
    default_respond(conn, 200, response)
  end

  def gotopreset(conn, %{"id" => id, "preset_token" => token}) do
    [url, username, password] = Camera.get_camera_info id
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.goto_preset(url, username, password, profile, token)
    default_respond(conn, 200, response)
  end

  def setpreset(conn, %{"id" => id, "preset_token" => token}) do
    [url, username, password] = Camera.get_camera_info id
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.set_preset(url, username, password, profile, "", token)
    default_respond(conn, 200, response)
  end

  def createpreset(conn, %{"id" => id, "preset_name" => name}) do
    [url, username, password] = Camera.get_camera_info id
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.set_preset(url, username, password, profile, name)
    default_respond(conn, 200, response)
  end

  def continuousmove(conn, %{"id" => id, "direction" => direction}) do
    [url, username, password] = Camera.get_camera_info id
    velocity =
      case direction do
        "left" -> [x: -0.1, y: 0.0]
        "right" -> [x: 0.1, y: 0.0]
        "up" -> [x: 0.0, y: 0.1]
        "down" -> [x: 0.0, y: -0.1]
        _ -> [x: 0.0, y: 0.0]
      end
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.continuous_move(url, username, password, profile, velocity)
    default_respond(conn, 200, response)
  end

  def continuouszoom(conn, %{"id" => id, "mode" => mode}) do
    [url, username, password] = Camera.get_camera_info id
    velocity =
      case mode do
        "in" -> [zoom: 0.01]
        "out" -> [zoom: -0.01]
        _ -> [zoom: 0.0]
      end
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.continuous_move(url, username, password, profile, velocity)
    default_respond(conn, 200, response)
  end

  def relativemove(conn, %{"id" => id} = params) do
    [url, username, password] = Camera.get_camera_info id

    left = Map.get(params, "left", "0") |> String.to_integer
    right = Map.get(params, "right", "0") |> String.to_integer
		up = Map.get(params, "up", "0") |> String.to_integer
    down = Map.get(params, "down", "0") |> String.to_integer
    zoom = Map.get(params, "zoom", "0") |> String.to_integer
    x =
      cond do
        right > left -> right
        true -> -left
      end
    y =
      cond do
        down > up -> down
        true -> -up
      end
    profile = "Profile_1"
    {:ok, response} = ONVIFPTZ.relative_move(
      url, username,
      password, profile,
      [x: x / 100.0, y: y / 100.0, zoom: zoom / 100.0]
    )
    default_respond(conn, 200, response)
  end

  defp default_respond(conn, code, response) do
    conn
    |> put_status(code)
    |> put_resp_header("access-control-allow-origin", "*")
    |> json response
  end

end
