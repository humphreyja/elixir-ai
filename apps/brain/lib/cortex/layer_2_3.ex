defmodule Cortex.Layer23 do
  use GenServer

  def start_link(:default) do
    GenServer.start_link(__MODULE__, :ok, %{})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def layer4_input(server, data) do
    GenServer.cast(server, {:layer4_input, data})
  end

  def handle_cast({:layer4_input, data}, state) do
    {:noreply, state}
  end
end
