defmodule Thalamus.Core do
  use GenServer

  def start_link(:default) do
    GenServer.start_link(__MODULE__, :ok, %{})
  end

  def init(:ok) do
    # TODO (Thalamus): Spawn regions to handle input.
    {:ok, %{}}
  end

  def sensory_input(region, data) do
    # TODO (Thalamus): Handle input from a type of sensor.
    GenServer.cast(region, {:sensory_input, data})
  end

  def cortex_input(region, data) do
    # TODO (Thalamus): Handle input from cortex layer 6.
    GenServer.cast(region, {:cortex_input, data})
  end

  def basal_ganglia_input(region, data) do
    # TODO (Thalamus): Handle input from basal ganglia.
    GenServer.cast(region, {:basal_ganglia_input, data})
  end

  def handle_cast({:sensory_input, data}, state) do
    # TODO: (Thalamus): Take in the input, subtract previous input, pass final input to cortex region.
    {:noreply, state}
  end

  def handle_cast({:cortex_input, data}, state) do
    # TODO (Thalamus): Store that input in the state for subtracting from new input.
    # TODO (Thalamus): Send data to basal ganglia(matrix instead of core?)
    {:noreply, state}
  end

  def handle_cast({:basal_ganglia_input, data}, state) do
    # TODO (Thalamus): Inhibit inputs based on data.
    {:noreply, state}
  end
end
