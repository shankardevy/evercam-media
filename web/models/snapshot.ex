defmodule Snapshot do
  use Ecto.Model
  use Timex.Ecto.DateTime

  schema "snapshots" do
    belongs_to :camera, Camera

    field :data, :string
    field :notes, :string
    field :motionlevel, :integer
    field :created_at, Ecto.DateTime, default: Ecto.DateTime.utc
  end

  def for_camera(camera_id) do
    from snap in Snapshot,
    where: snap.camera_id == ^camera_id,
    select: snap
  end

  def for_camera(camera_id,ts) do
    timestamp = Timex.Ecto.DateTime.cast(ts)
    from snap in Snapshot,
    where: snap.camera_id == ^camera_id and snap.created_at == ^timestamp,
    select: snap,
    preload: :camera
  end
end
