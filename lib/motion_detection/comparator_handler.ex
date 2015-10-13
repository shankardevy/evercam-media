defmodule EvercamMedia.MotionDetection.ComparatorHandler do
  use GenEvent
  require Logger

  @moduledoc """
  TODO
  """

  def handle_event({:got_snapshot, data}, state) do
    {camera_exid, timestamp, image} = data
    image_byte_size = byte_size image
    Logger.info "Inside EvercamMedia.MotionDetection.ComparatorHandler -> handle_event"
    Logger.info "camera_exid=#{camera_exid}"

    camera_exid_last = "#{camera_exid}_last"
    camera_exid_previous = "#{camera_exid}_previous"

    # last_timestamp = result[:timestamp]
    # last_notes = result[:notes]

    last = ConCache.get(:cache, camera_exid_last)
    previous = ConCache.get(:cache, camera_exid_previous)

    last_image = last[:image]
    previous_image = previous[:image]

    Logger.info "last = #{last[:timestamp]}, previous = #{previous[:timestamp]}"

    if last_image && previous_image do
      EvercamMedia.MotionDetection.Lib.init
      motion_level = EvercamMedia.MotionDetection.Lib.compare(last_image,previous_image)
      Logger.info "motion_level = #{motion_level}"
    end

    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

end
