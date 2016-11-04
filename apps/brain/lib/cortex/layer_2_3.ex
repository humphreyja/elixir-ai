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
    {:ok, %{sense: sense, name: name, inhibitory_name: inhibitory_name, action_potential: [], awake: true, predicting: false}}
  end

  def associate(server, column_cells) do
     GenServer.cast(server, {:construct_column_association, column_cells})
  end

  def handle_cast({:construct_column_association, column_cells}, state) do
    state = Map.merge(state, %{column: column_cells})
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
    {:ok, column} = Map.fetch(state, :column)
    {:ok, l4_cells} = Map.fetch(column, :l4)
    {:ok, strength} = Map.fetch(l4_cells, l4_name)
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

  def handle_cast(:column_fire, state) do
    {:ok, column} = Map.fetch(state, :column)
    {:ok, l6_cells} = Map.fetch(column, :l6)
    {:ok, l5_cells} = Map.fetch(column, :l5)

    IO.puts "---------------->>> COLUMN FIRE"
    {l6_cell, _} = Enum.at(l6_cells, 0)
    Cortex.Layer6.layer_23_input(l6_cell, name)

    {l5_cell, _} = Enum.at(l5_cells, 0)
    Cortex.Layer5.layer_23_input(l5_cell, name)

    {:noreply, state}
  end

  @doc """
  When a cell is selected to fire, first, all of the synapses that built up to
  the action potential are grown stronger.  Then the cell is put into a recovery
  state where it will not receive input until the designated time.
  """
  def handle_cast(:fire, state) do
    {:ok, name} = Map.fetch(state, :name)
    {:ok, action_potential} = Map.fetch(state, :action_potential)
    {:ok, column} = Map.fetch(state, :column)
    {:ok, l4_cells} = Map.fetch(column, :l4)
    {:ok, l6_cells} = Map.fetch(column, :l6)
    {:ok, l5_cells} = Map.fetch(column, :l5)
    {:ok, l23_cells} = Map.fetch(column, :l23)

    case Map.fetch(state, :predicting) do
      {:ok, true} -> fire_column(l23_cells, name)
      _err        -> nil
    end



    updated_l4_cells = Map.new(Enum.map(action_potential, fn (name) ->
      {:ok, synaptic_strength} = Map.fetch(l4_cells, name)
      {name, synaptic_strength + 1}
    end))

    l4_cells = Map.merge(l4_cells, updated_l4_cells)

    column = Map.merge(column, %{l4: l4_cells})
    state = Map.merge(state, %{column: column, action_potential: [], awake: false})
    GenServer.cast(self, {:wake_up_cell, @recovery_cycle_length})

    IO.puts "FIRE"
    {l6_cell, _} = Enum.at(l6_cells, 0)
    Cortex.Layer6.layer_23_input(l6_cell, name)

    {l5_cell, _} = Enum.at(l5_cells, 0)
    Cortex.Layer5.layer_23_input(l5_cell, name)

    {:noreply, state}
  end

  defp fire_column(column, name) do
    {_, rest_of_column} = Map.pop(column, name)
    Enum.map(rest_of_column, fn ({cell, _weight}) ->
        Task.async(fn ->
          GenServer.cast(cell, :column_fire)
        end)
    end)

    0
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
    {:ok, column} = Map.fetch(state, :column)
    {:ok, l4_cells} = Map.fetch(column, :l4)
    l4_cells = Map.new(Enum.map(l4_cells, fn ({name, strength}) ->
              if strength > 2 do
                {name, strength - 1}
              else
                {name, 1}
              end
            end))

    column = Map.merge(column, %{l4: l4_cells})
    state = Map.merge(state, %{column: column})
    {:noreply, state}
  end
end
