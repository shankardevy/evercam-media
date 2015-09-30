defmodule EvercamMedia.Worker do
  import EvercamMedia.Snapshot
  import EvercamMedia.Schedule

  def start_link(args) do
    IO.puts("Starting camera worker '#{args[:camera_exid]}'")
    worker_name = args[:camera_exid] |> String.to_atom
    GenServer.start_link(__MODULE__, args, name: worker_name)
  end

  def init(args) do
    {:ok, args}
  #  Task.start_link(fn -> loop(args) end)
  end

  defp loop(args) do
    :timer.sleep(args[:sleep] + args[:initial_sleep])
    args = Dict.put(args, :initial_sleep, 0)
    if scheduled?(args[:schedule], args[:timezone]) do
      Task.start_link(fn -> check_camera(args) end)
    end
    loop(args)
  end
end
