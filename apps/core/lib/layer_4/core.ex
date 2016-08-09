defmodule Layer4.Core do
  use GenServer

  def start_link(layer23) do
    GenServer.start_link(__MODULE__, layer23, [])
  end

  def init(layer23) do
    {:ok, %{layer23: layer23}}
  end

  def input(server, set) do
    GenServer.cast(server, {:input, set})
  end

  def handle_cast({:input, set}, state) do
    Layer23.Core.input(state[:layer23], set)
    {:noreply, state}
  end
end
