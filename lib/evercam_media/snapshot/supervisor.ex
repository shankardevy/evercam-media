defmodule EvercamMedia.Snapshot.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @event_manager_name EvercamMedia.Snapshot.EventManager
  @registry_name EvercamMedia.Snapshot.Registry
  @ets_registry_name EvercamMedia.Snapshot.Registry
  @camera_sup_name EvercamMedia.Snapshot.ClientSupervisor

  def init(:ok) do
    ets = :ets.new(@ets_registry_name,
                   [:set, :public, :named_table, {:read_concurrency, true}])

    children = [
      worker(GenEvent, [[name: @event_manager_name]]),
      supervisor(EvercamMedia.Snapshot.ClientSupervisor, [[name: @camera_sup_name]]),
      worker(EvercamMedia.Snapshot.Registry, [ets, @event_manager_name,
                           @camera_sup_name, [name: @registry_name]])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
