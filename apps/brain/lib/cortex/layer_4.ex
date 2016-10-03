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
    outputs = build_outputs(sense, name)
    {:ok, %{sense: sense, outputs: outputs, name: name}}
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
    {:ok, sense} = Map.fetch(state, :sense)
    {:ok, outputs} = Map.fetch(state, :outputs)
    {:ok, name} = Map.fetch(state, :name)
    Enum.map(outputs, fn (c_id) ->
        Task.async(fn ->
            broadcast_to_cell(cell_name(sense, 23, c_id), name)
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

  """
  Build cell name from sense prefix, layer, and cell id
  """
  defp cell_name(sense, layer, c_id) do
    String.to_atom Enum.join([sense.cell_name_prefix, layer, c_id], "_")
  end

  """
  Build projections to cells in layer 23.

  NOTE: Because of an error with Enum.count, I simplified this from
        attempting to programmably get an even set of projections across the
        entire layer, to randomly building the projections.  See the
        commented out code below.
  """
  defp build_outputs(sense, name) do
    # get list of indexes that are not already used
    total_outputs = sense.layer_23_count
    total_output_list = 1..total_outputs

    #randomize
    total_output_list = Enum.take_random(total_output_list, 10)
    Enum.map(total_output_list, fn (nl) ->
      Cortex.Layer23.add_input(cell_name(sense, 23, nl), name)
    end)

    total_output_list
    #build_output(sense, total_output_list, [], total_output_list, name)
  end

  # defp build_outputs(sense, name) do
  #
  #   # get list of indexes that are not already used
  #   total_outputs = sense.layer_23_count
  #   total_output_list = 1..total_outputs
  #
  #   #randomize
  #   total_output_list = Enum.take_random(total_output_list, Enum.count(total_output_list))
  #
  #   build_output(sense, total_output_list, [], total_output_list, name)
  # end

  # defp build_output(sense, [c_id | rest], output_list, all_outputs, name) do
  #   if Enum.count(output_list) > 10 do
  #     output_list
  #   else
  #     c_name = cell_name(sense, 23, c_id)
  #     output_list = if Cortex.Layer23.number_of_inputs(c_name) < 3 do
  #                     Cortex.Layer23.add_input(c_name, name)
  #                     output_list ++ [c_id]
  #                   end
  #
  #     build_output(sense, rest, output_list, all_outputs, name)
  #   end
  # end
  #
  # defp build_output(sense, [], output_list, all_outputs, name) do
  #   total_count = Enum.count(output_list)
  #   output_list = if total_count <= 10 do
  #                   new_list = Enum.take_random(all_outputs, 10 - total_count)
  #                   Enum.map(new_list, fn (nl) ->
  #                     c_name = cell_name(sense, 23, nl)
  #                     Cortex.Layer23.add_input(c_name, name)
  #                   end)
  #                   output_list ++ new_list
  #                 end
  #
  #   output_list
  # end
end
