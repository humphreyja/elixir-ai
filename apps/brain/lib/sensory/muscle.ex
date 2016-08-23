defmodule Sensory.Muscle do
  use GenServer

  def start_link(:default) do
    GenServer.start_link(__MODULE__, :ok, %{})
  end

  def init(:ok) do
    # TODO (Sensory): Spawn executable for motor.  Store process in state.
    {:ok, %{}}
  end

  def move(server, data) do
    # TODO (Sensory): Move motor.
    GenServer.cast(server, {:move, data})
  end

  def handle_cast({:move, data}, state) do
    # TODO: (Sensory): Move the motor accourding to data
    {:noreply, state}
  end
end
