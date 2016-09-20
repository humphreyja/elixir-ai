defmodule Cortex.Layer23 do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def layer4_input(server, data) do
    GenServer.cast(server, {:layer4_input, data})
  end

  def handle_cast({:layer4_input, data}, state) do
    IO.puts "L23 from L4 #{inspect data}"
    {:noreply, state}
  end
end
