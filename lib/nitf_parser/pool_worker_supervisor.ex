defmodule NitfParser.PoolWorkerSupervisor do
  use Supervisor

  @name __MODULE__

  def start_link() do
    Supervisor.start_link(__MODULE__, [], [ name: @name])
  end

  def init(_) do
    opts = [ strategy: :simple_one_for_one, max_restarts: 5, max_seconds: 1 ]
    children = [
      worker(NitfParser.Worker, [])
    ]

    # supervise/2 is imported from Supervisor.Spec
    supervise(children, opts)
  end

  def start_worker() do
    Supervisor.start_child(@name, [])
  end
end
