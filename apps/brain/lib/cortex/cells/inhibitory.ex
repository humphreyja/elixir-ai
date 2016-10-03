defmodule Cortex.Cells.Inhibitory do
  use GenServer

  @receive_input_cycle_length 40
  @reject_input_cycle_length 20
  @atrophy_cycle_time 100000

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    Brain.atrophy(__MODULE__, self, @atrophy_cycle_time)
    {:ok, %{cells: %{}, inputs: %{}, awake: true}}
  end

  @doc """
  Adds a cell to the inhibitory cell list
  """
  def add_cell(server, cell_name) do
     GenServer.cast(server, {:insert_cell, cell_name})
  end

  def handle_cast({:insert_cell, cell_name}, state) do
    {:ok, cells} = Map.fetch(state, :cells)
    cells = Map.put(cells, cell_name, 1) # TODO: Implement Synapse for constraint issues
    state = Map.merge(state, %{cells: cells})
    {:noreply, state}
  end

  @doc """
  Each time a 23 cell receives a layer 4 input, it will forward the input
  to the inhibitory cell
  """
  def layer_23_input(server, cell_name, synapse_strenght) do
    GenServer.cast(server, {:layer_23_input, cell_name, synapse_strenght})
  end

  @doc """
  The input get accumulated. On first input, a countdown is started so that
  the inhibitory cell is only listening for 40 mil seconds
  """
  def handle_cast({:layer_23_input, cell_name, synapse_strenght}, state) do
    case Map.fetch(state, :awake) do
      {:ok, true} -> receive_inputs(cell_name, synapse_strenght, state)
      _else       -> {:noreply, state}
    end
  end

  """
  Runs only if the cell is in a state of awakeness
  """
  defp receive_inputs(cell_name, synapse_strength, state) do
    {:ok, inputs} = Map.fetch(state, :inputs)
    if Enum.count(inputs) == 0 do
      GenServer.cast(self, :complete_listening_stage)
    end
    current_strength =  case Map.fetch(inputs, cell_name) do
                          {:ok, strength} -> strength
                          _err            -> 0
                        end

    inputs = Map.put(inputs, cell_name, current_strength + synapse_strength)
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
    Cortex.Cells.Inhibitory.process_inputs(self, inputs)

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
    state = Map.merge(state, %{awake: true})
    {:noreply, state}
  end


  @doc """
  Once the cell finished listening, cast to the server all the inputs to process
  """
  def process_inputs(server, inputs) do
     GenServer.cast(server, {:process_inputs, inputs})
  end

  @doc """
  Go through each input, dtermine which is the best, inhibit the rest, fire the strongest
  """
  def handle_cast({:process_inputs, inputs}, state) do
    {:ok, cells} = Map.fetch(state, :cells)
    largest_name = determine_strongest_cell(Map.to_list(inputs), 0, nil, cells)
    inhibit_cells = Map.drop(cells, [largest_name])

    # Map through each of the weaker cells and inhibit them
    Enum.map(inhibit_cells, fn ({name, strength}) ->
        Task.async(fn ->
            Cortex.Layer23.inhibit(name)
        end)
    end)

    # Fire the strongest cell
    Cortex.Layer23.fire(largest_name)

    # Increase the strength of the relationship between a cell and the inhibitory cell
    largest_inhibit_strength =  case Map.fetch(cells, largest_name) do
                                  {:ok, strength} -> strength
                                  _err            -> 1
                                end
    cells = Map.put(cells, largest_name, largest_inhibit_strength + 1)
    state = Map.merge(state, %{cells: cells})
    {:noreply, state}
  end

  """
  Map through each input to find the strongest
  """
  defp determine_strongest_cell([], _largest, strongest_name, _cells), do: strongest_name
  defp determine_strongest_cell([{name, strength}|rest], largest, strongest_name, cells) do
    {:ok, cell} = Map.fetch(cells, name)
    strength = calc_strength(strength, cell)
    if strength > largest do
      determine_strongest_cell(rest, strength, name, cells)
    else
      determine_strongest_cell(rest, largest, strongest_name, cells)
    end
  end

  """
  The true strength of a cells action potential is calculated by taking the
  total strength (total of each synapse strength that fired) and dividing by
  the strength of the relationship to the inhibitory cell.  This ensures that if
  a cell has not fired in a long time, it is much less likely to be inhibited.
  """
  defp calc_strength(strength, inhibitory_strength) do
    strength / inhibitory_strength
  end

  def atrophy(server) do
    GenServer.cast(server, :atrophy)
  end

  @doc """
  Decrements the strengths of all of the relationships to the cell.
  Use if or lose it.
  """
  def handle_cast(:atrophy, state) do
    {:ok, cells} = Map.fetch(state, :cells)
    cells = Map.new(Enum.map(cells, fn ({name, strength}) ->
              if strength > 2 do
                {name, strength - 1}
              else
                {name, 1}
              end
            end))

    state = Map.merge(state, %{cells: cells})
    {:noreply, state}
  end
end
