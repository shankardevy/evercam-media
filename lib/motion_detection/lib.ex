defmodule EvercamMedia.MotionDetection.Lib do
  require Logger
  @on_load :init

  def init() do
    :erlang.load_nif("./priv_dir/lib_elixir_motiondetection", 0)
    # TODO: Uncomment this, if you have deployment problems with the Makefile
    # :ok
  end

  def compare(image1,image2) do
    {:ok,{width1,height1,bytes1}} = load image1
    {:ok,{_width2,_height2,bytes2}} = load image2

    # use this to parallel the process, and play with the quality and performance
    position    = width1*height1*3 # end position for a process
    minPosition = 0 # start position for a process in a binary list of pixesl {R,G,B}
    step      = 2 # check each 2nd pixel
    min     = 30 # change between previous and current image should be at least

    result = compare bytes1, bytes2, position, minPosition, step, min
    motion_level = round(result * 100)
    # Logger.info "EvercamMedia.MotionDetection.Lib Comparison result is #{result} and motion_level = #{motion_level}"

    motion_level

  end

  # rest of the routine

  def load(_Binary) do
    _load(_Binary)
  end

  def compare(_B1,_B2,_Pos,_MinPos,_Step,_Min) do
    _compare(_B1,_B2,_Pos,_MinPos,_Step,_Min)
  end

  def _test(images_path) do
    "NIF library not loaded. Trying to call method `_load`. And to pass #{images_path}"
  end

  def _load(_Binary) do
    "NIF library not loaded. Trying to call method `_load`."
  end

  def _compare(_B1,_B2,_Pos,_MinPos,_Step,_Min) do
    "NIF library not loaded. Trying to call method `_compare`."
  end
end
