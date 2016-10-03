defmodule Cortex.Layer4 do
  use GenServer

  @doc """
  Start a new cell process with the given name
  """
  def start_link(name, sense) do
    GenServer.start_link(__MODULE__, [sense, name], name: name)
  end

  @doc """
  Initializes the cell with the given sense and constructs a
  set of projections to layer23.
  """
  def init([sense, name]) do
    {:ok, %{sense: sense, column: %{}, name: name}}
  end

  def associate(server, column_cells) do
     GenServer.cast(server, {:construct_column_association, column_cells})
  end

  def handle_cast({:construct_column_association, column_cells}, state) do
    state = Map.merge(state, %{column: column_cells})
    {:noreply, state}
  end

  @doc """
  Recieve input from a thalamus projection
  """
  def thalamus_input(server) do
    GenServer.cast(server, {:thalamus_input, server})
  end

  @doc """
  Broadcast to each one of the layer 23 cells that this cell projects to.
  """
  def handle_cast({:thalamus_input, data}, state) do
    state = broadcast(state)
    {:noreply, state}
  end

  """
  Broadcast async to each projected cell in layer 23
  """
  defp broadcast(state) do
    {:ok, column} = Map.fetch(state, :column)
    {:ok, l23_cells} = Map.fetch(column, :l23)
    {:ok, name} = Map.fetch(state, :name)
    Enum.map(l23_cells, fn ({cell, _weight}) ->
        Task.async(fn ->
            broadcast_to_cell(cell, name)
        end)
    end)

    state
  end

  """
  Broadcast to cell with pid_name
  """
  defp broadcast_to_cell(pid_name, l4_name) do
    Cortex.Layer23.layer4_input(pid_name, l4_name)
  end
end
