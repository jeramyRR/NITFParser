defmodule NitfParser.Pool do
  use GenServer

  @name :nitf_worker_pool

  ## Client API

  def start_link(num_workers \\ 10) do
    GenServer.start_link(__MODULE__, num_workers, [ name: @name])
  end

  def num_workers_available() do
    GenServer.call(@name, :workers_in_pool)
  end

  def checkout() do
    GenServer.call(@name, :checkout)
  end

  def checkin(worker) do
    GenServer.cast(@name, {:checkin, worker})
  end

  ## Server API

  def init(num_workers) do
    spawn(fn -> send(@name, {:init_workers, num_workers}) end)
    {:ok, []}
  end

  def handle_call(:workers_in_pool, _from, state) do
    {:reply, Enum.count(state), state}
  end

  def handle_call(:checkout, _from, workers) do
    case workers do
      [ worker | rest ] ->
        {:reply, worker, rest}

      [] ->
        {:reply, :noproc, workers}
    end
  end

  def handle_cast({:checkin, worker}, state) do
      {:noreply, [ worker | state ]}
  end

  def handle_info({:init_workers, num_workers}, _state) do
    new_state = Enum.map(1..num_workers, fn _ ->
      {:ok, pid} = NitfParser.Worker.start_link
      pid
    end)
    {:noreply, new_state }
  end

  ## Helper Functions

end
