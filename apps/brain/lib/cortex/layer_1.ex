defmodule Cortex.Layer1 do
  use GenServer

  def start_link(name, sense) do
    GenServer.start_link(__MODULE__, sense, name: name)
  end

  def init(sense) do
    {:ok, %{sense: sense}}
  end

  def thalamus_input(server, data) do
    GenServer.cast(server, {:thalamus_input, data})
  end

  def handle_cast({:thalamus_input, data}, state) do
    IO.puts "L1 from Thalamus #{inspect data}"
    {:noreply, state}
  end
end
