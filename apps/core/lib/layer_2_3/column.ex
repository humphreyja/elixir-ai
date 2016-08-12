defmodule Layer23.Column do
  use GenServer

  @cell_count 5

  @doc """
  Sends an input to the column server
  """
  def send_input(server, input) do
    case GenServer.call(server, {:input, input}) do
      {:ok, weight} ->
        weight
      {:error, _} ->
        nil
    end
  end

  def fire(server, input) do
    GenServer.cast(server, {:fire, input})
  end

  @doc """
  Starts the server with the given input
  """
  def start_link(input) do
    GenServer.start_link(__MODULE__, input, [])
  end

  @doc """
  Initializes the column with an input
  """
  def init(input) do
    weights = assign_random_weights(MapSet.to_list(input), %{})
    cells = add_cells(@cell_count)
    {:ok, %{input: input, weight: weights, cells: cells}}
  end

  @doc """
  Adds a child process with the given name
  """
  defp add_cell do
    {:ok, pid} = Layer23.Cell.start_link
    pid
  end

  @doc """
  Creates `count` may columns with a random sample of inputs they will cover
  """
  defp add_cells(count) do
    if count > 1 do
      [add_cell] ++ add_cells(count - 1)
    else
      [add_cell]
    end
  end

  # TODO: (SPEED) - Run map function in async
  def handle_cast({:fire, input}, state) do
    new_weights = state[:weight]
      |> Enum.map(fn {key, value} -> {key, adjust_weight(key, value, input)}  end)

    # Update state with new weights
    state = Map.put(state, :weight, Map.new(new_weights))

    # TODO: (STEP 5) - Pass input to cells for selected cells in column (TP)
    # TODO: (STEP 7) - Based on cells that will fire, select one cell to fire
    {:noreply, state}
  end

  defp adjust_weight(key, value, input) do
    case MapSet.member?(input, key) do
      true ->
        value + 1
      false ->
        value - 1
    end
  end

  def handle_call({:input, input}, _from, state) do
    # DONE: (STEP 2) - Check if input matches column state, return a weight if true

    input_list = input
                 |> Enum.map(fn (elem) -> select_if_weighted(elem, state[:weight]) end)
                 |> Enum.filter(fn (elem) -> (elem != nil) end)
    weight = Enum.count(input_list)
    {:reply, {:ok, weight}, state}
  end

  defp select_if_weighted(input, weights) do
    # TODO: (STEP 8) - Validate columns don't need predictive state
    case Map.fetch(weights, input) do
      {:ok, weight} ->
        if weight >= 40 do
          input
        else
          nil
        end
      :error ->
        nil
    end
  end

  defp assign_random_weights([input | rest], map) do
    weight = Enum.random(1..100)
    assign_random_weights(rest, Map.put(map, input, weight))
  end

  defp assign_random_weights([], map) do
    map
  end


end
