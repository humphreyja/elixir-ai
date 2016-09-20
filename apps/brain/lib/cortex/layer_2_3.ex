defmodule Cortex.Layer23 do
  use GenServer

  def start_link(name, sense) do
    GenServer.start_link(__MODULE__, sense, name: name)
  end

  def init(sense) do
    {:ok, %{sense: sense, inputs: %{}}}
  end

  def number_of_inputs(server) do
    GenServer.call(server, {:number_of_inputs})
  end

  def add_input(server, l4_id) do
    GenServer.cast(server, {:add_input, l4_id})
  end

  def layer4_input(server) do
    GenServer.cast(server, {:layer4_input, server})
  end

  def handle_call({:number_of_inputs}, _, state) do
    {:ok, inputs} = Map.fetch(state, :inputs)
    total = Enum.count(inputs)
    {:reply, total, state}
  end

  def handle_cast({:layer4_input, data}, state) do
    IO.puts "L23 from L4 #{inspect data}"
    {:noreply, state}
  end

  def handle_cast({:add_input, data}, state) do
    {:ok, inputs} = Map.fetch(state, :inputs)
    inputs = Map.put(inputs, data, 0)
    state = Map.merge(state, %{inputs: inputs})
    {:noreply, state}
  end
end
