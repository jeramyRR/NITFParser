defmodule NitfParser.PoolSupervisor do
  use Supervisor

  @name __MODULE__

  def start_link() do
    Supervisor.start_link(__MODULE__, [], [ name: @name])
  end

  def init(_) do
    children = [
      supervisor(NitfParser.PoolWorkerSupervisor, []),
      worker(NitfParser.PoolServer, [])
    ]

    # supervise/2 is imported from Supervisor.Spec
    supervise(children, strategy: :one_for_all)
  end
end
