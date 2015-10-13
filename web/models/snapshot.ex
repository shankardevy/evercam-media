defmodule Snapshot do
  use Ecto.Model

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

  def for_camera(camera_id,timestamp) do
    # ^%{__struct__: Ecto.DateTime, day: 13, hour: 23, min: 5, month: 10, sec: 47, usec: 0, year: 2015},
    from snap in Snapshot,
    where: snap.camera_id == ^camera_id
    #  and snap.created_at == ^timestamp,
    select: snap,
    order_by: [desc: snap.created_at],
    limit: 1
  end
end
