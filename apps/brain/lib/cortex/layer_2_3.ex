defmodule Cortex.Layer23 do
  use GenServer

  @recovery_cycle_length 40 # if a cell fires
  @inhibited_cycle_length 40 # if a cell is inhibited
  @atrophy_cycle_time 100000

  def start_link(name, inhibitory_name, sense) do
    GenServer.start_link(__MODULE__, [sense, name, inhibitory_name], name: name)
  end

  def init([sense, name, inhibitory_name]) do
    Brain.atrophy(__MODULE__, self, @atrophy_cycle_time)
    {:ok, %{sense: sense, name: name, inhibitory_name: inhibitory_name, inputs: %{}, action_potential: [], awake: true}}
  end

  def associate(server, column_cells) do
     GenServer.cast(server, {:construct_column_association, column_cells})
  end

  def handle_cast({:construct_column_association, column_cells}, state) do
    state = Map.merge(state, %{column: column_cells})
    {:noreply, state}
  end

  @doc """
  Adds a layer 4 input cell to the list of inputs
  """
  def add_input(server, l4_id) do
    GenServer.cast(server, {:add_input, l4_id})
  end

  def handle_cast({:add_input, data}, state) do
    {:ok, inputs} = Map.fetch(state, :inputs)
    inputs = Map.put(inputs, data, 1)
    state = Map.merge(state, %{inputs: inputs})
    {:noreply, state}
  end

  @doc """
  Receives input from a layer 4 input cell
  """
  def layer4_input(server, l4_name) do
    GenServer.cast(server, {:layer4_input, l4_name})
  end

  @doc """
  After receiving input from layer 4, it sends the input and the synaptic strength
  to the designated inhibitory cell.  It then adds the synapse to the action
  potential list.
  """
  def handle_cast({:layer4_input, l4_name}, state) do
    {:ok, inputs} = Map.fetch(state, :inputs)
    {:ok, strength} = Map.fetch(inputs, l4_name)
    {:ok, inhibitory_name} = Map.fetch(state, :inhibitory_name)
    {:ok, name} = Map.fetch(state, :name)

    # TODO: Send column name as well
    # Send input to inhibitory cell
    Cortex.Cells.Inhibitory.layer_23_input(inhibitory_name, name, strength)

    {:ok, action_potential} = Map.fetch(state, :action_potential)
    action_potential = action_potential ++ [l4_name]
    state = Map.put(state, :action_potential, action_potential)
    {:noreply, state}
  end

  @doc """
  After the inhibitory cell handles inputs from a bunch of other cells, it selects
  which layer 2/3 cell to fire.  All other cells are inhibited.
  """
  def fire(server) do
    GenServer.cast(server, :fire)
  end

  @doc """
  After the inhibitory cell handles inputs from a bunch of other cells, it selects
  which layer 2/3 cell to fire.  All other cells are inhibited.
  """
  def inhibit(server) do
    GenServer.cast(server, :inhibit)
  end

  @doc """
  When a cell is selected to fire, first, all of the synapses that built up to
  the action potential are grown stronger.  Then the cell is put into a recovery
  state where it will not receive input until the designated time.
  """
  def handle_cast(:fire, state) do
    {:ok, name} = Map.fetch(state, :name)
    {:ok, action_potential} = Map.fetch(state, :action_potential)
    {:ok, inputs} = Map.fetch(state, :inputs)

    updated_inputs = Map.new(Enum.map(action_potential, fn (name) ->
      {:ok, synaptic_strength} = Map.fetch(inputs, name)
      {name, synaptic_strength + 1}
    end))

    inputs = Map.merge(inputs, updated_inputs)

    state = Map.merge(state, %{inputs: inputs, action_potential: [], awake: false})
    GenServer.cast(self, {:wake_up_cell, @recovery_cycle_length})
    IO.puts "FIRE"
    {:noreply, state}
  end

  @doc """
  If a cell is inhibited, the cell will not be able to receive input until the
  designated time is up.
  """
  def handle_cast(:inhibit, state) do
    state = Map.merge(state, %{action_potential: [], awake: false})
    GenServer.cast(self, {:wake_up_cell, @inhibited_cycle_length})
    {:noreply, state}
  end

  @doc """
  Sets the cell in a state where it will receive inputs again
  """
  def handle_cast({:wake_up_cell, time}, state) do
    :timer.sleep(time)
    state = Map.merge(state, %{awake: true})
    {:noreply, state}
  end

  def atrophy(server) do
    GenServer.cast(server, :atrophy)
  end

  @doc """
  Decrements the strengths of all of the relationships to the cell.
  Use if or lose it.
  """
  def handle_cast(:atrophy, state) do
    {:ok, inputs} = Map.fetch(state, :inputs)
    inputs = Map.new(Enum.map(inputs, fn ({name, strength}) ->
              if strength > 2 do
                {name, strength - 1}
              else
                {name, 1}
              end
            end))

    state = Map.merge(state, %{inputs: inputs})
    {:noreply, state}
  end
end
