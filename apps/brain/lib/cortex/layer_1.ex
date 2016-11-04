defmodule Cortex.Layer1 do
  use GenServer

  def start_link(name, sense) do
    GenServer.start_link(__MODULE__, sense, name: name)
  end

  def init(sense) do
    {:ok, %{sense: sense, column: %{}, previous_input: %{}}}
  end

  def associate(server, column_cells) do
     GenServer.cast(server, {:construct_column_association, column_cells})
  end

  def handle_cast({:construct_column_association, column_cells}, state) do
    state = Map.merge(state, %{column: column_cells})
    {:noreply, state}
  end

  def thalamus_input(prefix, cells) do
    GenServer.cast(Cortex.Layer1.prefix_to_name(prefix), {:thalamus_input, cells})
  end

  def handle_cast({:thalamus_input, cells}, state) do
    IO.puts "L1 from Thalamus #{inspect cells}"
    state = Map.put(state, :previous_input, cells)
    {:noreply, state}
  end

  def get_previous_input(prefix) do
    GenServer.call(Cortex.Layer1.prefix_to_name(prefix), {:previous_input})
  end

  def handle_call({:previous_input}, _from, state) do
    case Map.fetch(state, :previous_input) do
      {:ok, input} -> {:reply, input, state}
      _err         -> {:reply, [], state}
    end
  end

  def prefix_to_name(prefix) do
    String.to_atom "#{prefix}_1"
  end
end
