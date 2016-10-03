defmodule Cortex.Layer5 do
  use GenServer

  def start_link(name, sense) do
    GenServer.start_link(__MODULE__, sense, name: name)
  end

  def init(sense) do
    {:ok, %{sense: sense}}
  end

  def associate(server, column_cells) do
     GenServer.cast(server, {:construct_column_association, column_cells})
  end

  def handle_cast({:construct_column_association, column_cells}, state) do
    state = Map.merge(state, %{column: column_cells})
    {:noreply, state}
  end

  def layer23_input(server, data) do
    GenServer.cast(server, {:layer_23_input, data})
  end

  def handle_cast({:layer_23_input, data}, state) do
    IO.puts "L5 from/to Thalamus #{inspect data}"
    {:noreply, state}
  end
end
