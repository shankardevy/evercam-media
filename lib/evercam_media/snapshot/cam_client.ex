defmodule EvercamMedia.Snapshot.CamClient do
  @moduledoc """
  Client to talk with the camera for various data. Currently this only fetches snapshots.
  In future, we could expand this module to check camera status, video stream etc.
  """

  alias EvercamMedia.HTTPClient
  alias EvercamMedia.Snapshot.Util
  require Logger

  @doc """
  Connect to the camera and get the snapshot
  """
  def fetch_snapshot(args) do
    [username, password] = String.split(args[:auth], ":")
    try do
      response =
        case args[:vendor_exid] do
          "samsung" -> HTTPClient.get(:digest_auth, args[:url], username, password)
          "ubiquiti" -> HTTPClient.get(:cookie_auth, args[:url], username, password)
          _ -> HTTPClient.get(:basic_auth, args[:url], username, password)
        end
      parse_snapshot_response(response)
    rescue
      error -> {:error, error}
    end
  end


  ## Private functions

  defp parse_snapshot_response(%HTTPotion.Response{status_code: 200} = response) do
    case Util.is_jpeg(response.body) do
      true -> {:ok, response.body}
      _ -> {:error, "Response not a jpeg image: #{inspect response}"}
    end
  end

  defp parse_snapshot_response(error) do
    {:error, error}
  end
end
