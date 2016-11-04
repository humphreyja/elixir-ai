defmodule Cortex.Layer5 do
  use GenServer

  @receive_input_cycle_length 40
  @reject_input_cycle_length 20

  def start_link(name, sense) do
    GenServer.start_link(__MODULE__, sense, name: name)
  end

  def init(sense) do
    {:ok, %{sense: sense, awake: true, inputs: %{}}}
  end

  def associate(server, column_cells) do
     GenServer.cast(server, {:construct_column_association, column_cells})
  end

  def handle_cast({:construct_column_association, column_cells}, state) do
    state = Map.merge(state, %{column: column_cells})
    {:noreply, state}
  end

  def layer_23_input(server, cell_name) do
    GenServer.cast(server, {:layer_23_input, cell_name})
  end

  def handle_cast({:layer_23_input, cell_name}, state) do
    case Map.fetch(state, :awake) do
      {:ok, true} -> receive_inputs(cell_name, state)
      _else       -> {:noreply, state}
    end
  end

  """
  Runs only if the cell is in a state of awakeness
  """
  defp receive_inputs(cell_name, state) do
    {:ok, inputs} = Map.fetch(state, :inputs)
    if Enum.count(inputs) == 0 do
      GenServer.cast(self, :complete_listening_stage)
    end
    inputs = Map.put(inputs, cell_name, :fire)
    state = Map.merge(state, %{inputs: inputs})
    {:noreply, state}
  end

  @doc """
  Runs after 40 mil seconds of listening for input.  Tells the
  gen server to process the inputs and clears the inputs from the state.
  This will limit it to running only once if it can.
  """
  def handle_cast(:complete_listening_stage, state) do
    :timer.sleep(@receive_input_cycle_length)
    {:ok, inputs} = Map.fetch(state, :inputs)
    {:ok, sense} = Map.fetch(state, :sense)
    Thalamus.Matrix.cortex_input(sense, inputs)

    # Clear the inputs
    state = Map.merge(state, %{inputs: %{}, awake: false})

    # The cell will reject any inputs while it is recovering from being fired
    GenServer.cast(self, :wake_up_cell)
    {:noreply, state}
  end

  @doc """
  Sets the cell in a state where it will receive inputs again
  """
  def handle_cast(:wake_up_cell, state) do
    :timer.sleep(@reject_input_cycle_length)
    state = Map.merge(state, %{inputs: %{}, awake: true})
    {:noreply, state}
  end
end
