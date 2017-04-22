defmodule NitfParser.Worker do
  alias NitfParser.Parser2

  ### Client API

  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end

  def parse(pid, file) do
    GenServer.call(pid, {:parse, file})
  end


  ### Server API

  def init(_) do
    {:ok, []}
  end

  def handle_call({:parse, file}, _from, state) do
    nitf_struct = Parser2.parse(file)
    {:reply, nitf_struct, state}
  end

end
