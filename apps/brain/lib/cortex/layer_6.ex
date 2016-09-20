defmodule Cortex.Layer6 do
  use GenServer

  def start_link(name, sense) do
    GenServer.start_link(__MODULE__, sense, name: name)
  end

  def init(sense) do
    {:ok, %{sense: sense}}
  end

  def thalamus_output(server, data) do
    GenServer.cast(server, {:thalamus_output, data})
  end

  def handle_cast({:thalamus_output, data}, state) do
    IO.puts "L6 from/to Thalamus #{inspect data}"
    {:noreply, state}
  end
end
