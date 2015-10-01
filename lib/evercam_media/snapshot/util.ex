defmodule EvercamMedia.Snapshot.Util do
  @moduledoc """
  Utility functions useful in snapshot fetching, processing or storing
  """

  @doc ~S"""
  Checks if a given binary data is a valid jpeg or not

  ## Examples

      iex> EvercamMedia.Snapshot.Util.is_jpeg("string")
      false

      iex> EvercamMedia.Snapshot.Util.is_jpeg("binaryimage")
      true
  """

  def is_jpeg(data) do
    case data do
      <<0xFF,0xD8, data :: binary>> -> true
      _ -> false
    end
  end

end
