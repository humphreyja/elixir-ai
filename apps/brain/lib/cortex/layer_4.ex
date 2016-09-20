defmodule Cortex.Layer4 do
  use GenServer

  def start_link(name, sense) do
    GenServer.start_link(__MODULE__, [sense, name], name: name)
  end

  def init([sense, name]) do

    outputs = build_outputs(sense, name)
    {:ok, %{sense: sense, outputs: outputs}}
  end

  def thalamus_input(server) do
    GenServer.cast(server, {:thalamus_input, server})
  end

  def handle_cast({:thalamus_input, data}, state) do
    state = broadcast(state)
    {:noreply, state}
  end

  defp broadcast(state) do
    {:ok, sense} = Map.fetch(state, :sense)
    {:ok, outputs} = Map.fetch(state, :outputs)
    Enum.map(outputs, fn (c_id) ->
        Task.async(fn ->
            broadcast_to_cell(cell_name(sense, 23, c_id))
        end)
    end)

    state
  end

  defp broadcast_to_cell(pid_name) do
    Cortex.Layer23.layer4_input(pid_name)
  end

  defp cell_name(sense, layer, c_id) do
    String.to_atom Enum.join([sense.cell_name_prefix, layer, c_id], "_")
  end

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
