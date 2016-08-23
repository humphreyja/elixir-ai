defmodule Cortex.Layer1 do
  use GenServer

  def start_link(:default) do
    GenServer.start_link(__MODULE__, :ok, %{})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def thalamus_input(server, data) do
    GenServer.cast(server, {:thalamus_input, data})
  end

  def handle_cast({:thalamus_input, data}, state) do
    {:noreply, state}
  end
end
