defmodule Cortex.Layer5 do
  use GenServer

  def start_link(:default) do
    GenServer.start_link(__MODULE__, :ok, %{})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def thalamus_output(server, data) do
    GenServer.cast(server, {:thalamus_output, data})
  end

  def handle_cast({:thalamus_output, data}, state) do
    {:noreply, state}
  end
end
