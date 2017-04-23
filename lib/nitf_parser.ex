defmodule NitfParser do
  use GenServer

  @name __MODULE__

  ## Client API

  def start_link() do
    GenServer.start_link(__MODULE__, [], [ name: @name ])
  end


  def parse_files(files) do
    files
    |> Enum.each(fn file -> GenServer.cast(@name, {:parse, file}) end)
  end

  def list_nitf_structs() do
    GenServer.call(@name, :list)
  end

  def clear() do
    GenServer.cast(@name, :clear)
  end


  ## Server API

  def init(_) do
    {:ok, []}
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:nitf_struct, nitf_struct}, state) do
    {:noreply, [ nitf_struct | state] }
  end

  def handle_cast({:parse, file}, state) do
    spawn(fn -> parse_file(file) end)
    {:noreply, state}
  end

  def handle_cast(:clear, _state) do
    {:noreply, []}
  end


  ## Helper Functions

  defp parse_file(file) do
    checkout_worker()
    |> worker_parse(file)
  end

  defp checkout_worker() do
    worker_pid = NitfParser.PoolServer.checkout
    worker_pid
  end

  defp worker_parse(:noproc, file) do
      Process.sleep(100)
      checkout_worker()
      |> worker_parse(file)
  end

  defp worker_parse(worker, file) do
    nitf_struct = NitfParser.Worker.parse(worker, file)
    NitfParser.PoolServer.checkin(worker)
    GenServer.cast(@name, {:nitf_struct, nitf_struct} )
  end

end
