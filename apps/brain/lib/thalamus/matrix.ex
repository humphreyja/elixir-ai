defmodule Thalamus.Matrix do
  use GenServer

  @name Thalamus.Matrix

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    # TODO (Thalamus): Get pids of all regions/layer1
    {:ok, %{}}
  end

  def cortex_input(region, data) do
    # TODO (Thalamus): Handle input from cortex layer 5.
    GenServer.cast(region, {:cortex_input, data})
  end

  def basal_ganglia_input(region, data) do
    # TODO (Thalamus): Handle input from basal ganglia.
    GenServer.cast(region, {:basal_ganglia_input, data})
  end

  def handle_cast({:cortex_input, data}, state) do
    # TODO (Thalamus): Pass data to layer 1 of all regions (or most)
    # TODO (Thalamus): Send data to basal ganglia(core instead of matrix?)
    {:noreply, state}
  end
end
