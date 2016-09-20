defmodule Cortex.Layer4 do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def thalamus_input(server, data) do
    GenServer.cast(server, {:thalamus_input, data})
  end

  def handle_cast({:thalamus_input, data}, state) do
    IO.puts "L4 from Thalamus #{inspect data}"
    {:noreply, state}
  end
end
