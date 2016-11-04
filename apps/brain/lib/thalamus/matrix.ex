defmodule Thalamus.Matrix do
  use GenServer

  @name Thalamus.Matrix
  @receive_input_cycle_length 100

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    # TODO (Thalamus): Get pids of all regions/layer1
    {:ok, %{input: %{}}}
  end

  def cortex_input(region, inputs) do
    GenServer.cast(__MODULE__, {:cortex_input, region, inputs})
  end

  def basal_ganglia_input(region, data) do
    # TODO (Thalamus): Handle input from basal ganglia.
    GenServer.cast(region, {:basal_ganglia_input, data})
  end

  def handle_cast({:cortex_input, region, inputs}, state) do
    # TODO (Thalamus): Pass data to layer 1 of all regions (or most)
    # TODO (Thalamus): Send data to basal ganglia(core instead of matrix?)

    {:ok, input} = Map.fetch(state, :input)
    if Enum.count(input) == 0 do
      GenServer.cast(self, :complete_listening_stage)
    end

    inputs = case Map.fetch(input, String.to_atom(region.cell_name_prefix)) do
      {:ok, curr_inputs} -> Map.merge(curr_inputs, inputs)
      _err               -> inputs
    end

    IO.puts "Saving l5: #{inspect inputs}"

    input = Map.put(input, String.to_atom(region.cell_name_prefix), inputs)
    state = Map.put(state, :input, input)
    {:noreply, state}
  end

  @doc """
  Runs after 40 mil seconds of listening for input.  Tells the
  gen server to process the inputs and clears the inputs from the state.
  This will limit it to running only once if it can.
  """
  def handle_cast(:complete_listening_stage, state) do
    :timer.sleep(@receive_input_cycle_length)
    {:ok, inputs} = Map.fetch(state, :input)
    IO.puts "Send to l1: #{inspect inputs}"
    Enum.map(inputs, fn ({region, cells}) ->
      Task.async(fn ->
        Cortex.Layer1.thalamus_input(region, cells)
      end)
    end)

    # Clear the inputs
    state = Map.merge(state, %{input: %{}})
    {:noreply, state}
  end
end
