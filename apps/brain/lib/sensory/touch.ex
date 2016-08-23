defmodule Sensory.Touch do
  use GenServer

  def start_link(:default) do
    GenServer.start_link(__MODULE__, :ok, %{})
  end

  def init(:ok) do
    # TODO (Sensory): Spawn executable for pressure sensor.  Store process in state.
    {:ok, %{}}
  end

  def read(server, data) do
    # TODO (Sensory): Initiate infinate read from pressure sensor.
    GenServer.cast(server, {:read, data})
  end

  def handle_cast({:read, data}, state) do
    # TODO: (Sensory): On each message, send data to Thalamus core.
    {:noreply, state}
  end
end
