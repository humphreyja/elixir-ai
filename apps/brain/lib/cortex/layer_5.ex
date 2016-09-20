defmodule Cortex.Layer5 do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def thalamus_output(server, data) do
    GenServer.cast(server, {:thalamus_output, data})
  end

  def handle_cast({:thalamus_output, data}, state) do
    IO.puts "L5 from/to Thalamus #{inspect data}"
    {:noreply, state}
  end
end
