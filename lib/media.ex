defmodule EvercamMedia do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(EvercamMedia.Endpoint, []),
      supervisor(EvercamMedia.Repo, []),
      # supervisor(EvercamMedia.Worker.Supervisor, []),
      supervisor(EvercamMedia.Snapshot.WorkerSupervisor, []),
      worker(ConCache, [[ttl_check: 100, ttl: 1500], [name: :cache]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EvercamMedia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EvercamMedia.Endpoint.config_change(changed, removed)
    :ok
  end
end
