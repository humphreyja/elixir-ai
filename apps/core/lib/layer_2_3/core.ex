defmodule Layer23.Core do
  use GenServer

  @column_count 10
  @inputs 1..100

  def start_link(layer1) do
    GenServer.start_link(__MODULE__, layer1, [])
  end

  def init(layer1) do
    input_set = MapSet.new(@inputs)
    columns = add_columns(@column_count, input_set, input_set)
    {:ok, %{layer1: layer1, columns: columns}}
  end

  def input(server, set) do
    GenServer.call(server, {:input, set})
  end

  @doc """
  Adds a child process with the given name
  """
  defp add_column(input) do
    {:ok, pid} = Layer23.Column.start_link(input)
    pid
  end

  @doc """
  Creates `count` may columns with a random sample of inputs they will cover
  """
  defp add_columns(count, input_set, sample_set) do
    # Amount of inputs a column will map to
    subset_count = div(MapSet.size(input_set), count) # 10

    # Get exclusive sample based on subset count
    exclusive_sample = MapSet.new(Enum.take_random input_set, subset_count) # 10

    remaining_set = MapSet.difference(sample_set, exclusive_sample) # 100 - 10


    # Get a sample of entire original set
    random_sample = MapSet.new(Enum.take_random remaining_set, subset_count) # 10 additional

    # ending sample is both exclusive and non exclusive inputs
    sample = MapSet.union(exclusive_sample, random_sample)

    if count > 1 do
      # TODO (CHOKE): Make sure this is Tail Recursive so it is fast
      # Create a list and add recursive items to the end
      [add_column(sample)] ++ add_columns(count - 1, MapSet.difference(input_set, exclusive_sample), sample_set)
    else
      [add_column(sample)]
    end
  end

  def handle_call({:input, set}, _from, state) do
    # DONE: (STEP 1) - broadcast to all columns
    columns = state[:columns]
            |> Enum.map(fn (elem) -> quick_gather(elem, set) end)
            |> Enum.filter(fn (elem) -> (elem != nil) end)

    IO.puts "COLUMNS: #{inspect columns}"
    weighted_map = build_list(columns, %{})
    min_sample = div(Enum.count(columns), 10) + 1

    weights = Enum.sort(Map.keys(weighted_map)) |> Enum.reverse

    # DONE: (STEP 3) - wait a time period, select only those columns, get top weights (SP)
    sample = sample_strongest(weights, weighted_map, min_sample)

    # DONE: (STEP 4) - fire columns and update weights
    # Fires all of the columns, setting predictive states and changing input weights
    fire_columns(sample, set)
    {:reply, sample, state}
  end

  def sample_strongest([weight | weaker], map, min) do
    case Map.fetch map, weight do
      {:ok, columns} ->
        length = Enum.count(columns)
        if length < min do
          columns ++ sample_strongest(weaker, map, min - length)
        else
          columns
        end
      :error ->
        []
    end
  end

  defp build_list([head | tail], map) do
    new_map = merge_weights(head, map)
    build_list(tail, new_map)
  end

  defp build_list([], map) do
    map
  end

  defp merge_weights(elem, map) do
    key = elem[:weight]
    if Map.has_key? map, key do
      case Map.fetch(map, key) do
        {:ok, value} ->
          Map.put(map, key, value ++ [elem[:column]])
        :error ->
          Map.put_new(map, key, [elem[:column]])
      end
    else
      Map.put(map, key, [elem[:column]])
    end
  end

  defp fire_columns(columns, input) do
    columns
    |> Enum.map(fn (col) -> Task.async(fn -> Layer23.Column.fire(col, input) end) end)
  end

  @doc """
  Broadcasts a message to a child, then waits for 100 milsecs to see if the child has replied
  """
  def quick_gather(child, input) do
    pid = Task.async(fn -> Layer23.Column.send_input(child, input) end)

    answer = case Task.yield(pid, 10) do
      {:ok, weight} ->
        %{column: child, weight: weight}
      nil ->
        nil
    end
    answer
  end
end
