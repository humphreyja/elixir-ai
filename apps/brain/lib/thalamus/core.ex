defmodule Thalamus.Core do
  @moduledoc """
  Receives input from a sense, converts it to a list of process ids and sends
  the processes a message.  This will be expanded to accept input from the cortex
  and influence the incomming input by removing any previous similar inputs.  Not sure
  if this is the correct approach yet.
  """
  use GenServer

  def start_link(sense) do
    GenServer.start_link(__MODULE__, sense, name: sense.thalamus_name)
  end

  def init(sense) do
    {:ok, %{sense: sense, previous_input: %{}}}
  end

  def cortex_input(server, cells) do
    GenServer.cast(server, {:cortex_input, cells})
  end

  def handle_cast({:cortex_input, cells}, state) do
    {:ok, previous_input} = Map.fetch(state, :previous_input)
    previous_input = Map.merge(previous_input, cells)
    state = Map.merge(state, previous_input)
    {:noreply, state}
  end


  # def basal_ganglia_input(region, data) do
  #   # TODO (Thalamus): Handle input from basal ganglia.
  #   GenServer.cast(region, {:basal_ganglia_input, data})
  # end
  #

  def sensory_input(region, data) do
    GenServer.cast(region, {:sensory_input, data})
  end

  def handle_cast({:sensory_input, data}, state) do
    {:ok, sense} = Map.fetch(state, :sense)
    Enum.map(data, fn (d) -> Task.async(fn -> send_to_cell(sense, d) end) end)
    {:noreply, state}
  end

  defp send_to_cell(sense, cell_id) do
    pid_name = String.to_atom Enum.join([sense.cell_name_prefix, 4, cell_id], "_")
    Cortex.Layer4.thalamus_input(pid_name)
  end

  #
  # def handle_cast({:cortex_input, data}, state) do
  #   # TODO (Thalamus): Store that input in the state for subtracting from new input.
  #   # TODO (Thalamus): Send data to basal ganglia(matrix instead of core?)
  #   {:noreply, state}
  # end
  #
  # def handle_cast({:basal_ganglia_input, data}, state) do
  #   # TODO (Thalamus): Inhibit inputs based on data.
  #   {:noreply, state}
  # end
end
