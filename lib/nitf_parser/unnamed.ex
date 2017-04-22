defmodule NitfParser.Unnamed do
  use GenServer

  @name :unnamed

  ## Client API

  def start_link() do
    GenServer.start_link(__MODULE__, [], [ name: :unnamed ])
  end


  def parse_files(files) do
    files
    |> Enum.each(fn file -> parse_file(file) end)
  end

  def get_nitf_structs() do
    GenServer.call(@name, :get_nitf_structs)
  end


  ## Server API

  def init(_) do
    {:ok, []}
  end

  def handle_call(:get_nitf_structs, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:nitf_struct, nitf_struct}, state) do
    {:noreply, [ nitf_struct | state] }
  end


  ## Helper Functions

  defp parse_file(file) do
    checkout_worker()
    |> worker_parse(file)
  end

  defp checkout_worker() do
    NitfParser.Pool.checkout
  end

  defp worker_parse(:noproc, file) do
      Process.sleep(100)
      checkout_worker()
      |> worker_parse(file)
  end

  defp worker_parse(worker, file) do
    nitf_struct = NitfParser.Worker.parse(worker, file)
    NitfParser.Pool.checkin(worker)
    GenServer.cast(@name, {:nitf_struct, nitf_struct} )
  end

end
