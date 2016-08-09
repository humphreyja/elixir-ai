defmodule Layer23.Column do
  use GenServer

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
    IO.puts "==========NEW COLUMN==========="
    IO.puts "assigned input #{inspect input}"
    IO.puts "weight #{inspect weights}"
    IO.puts ""
    {:ok, %{input: input, weight: weights}}
  end

  def handle_call({:input, input}, _from, state) do
    # TODO: (STEP 2) - Check if input matches column state, return a weight if true

    input_list = input
             |> Enum.map(fn (elem) -> select_if_weighted(elem, state[:weight]) end)
             |> Enum.filter(fn (elem) -> (elem != nil) end)
    weight = Enum.count(input_list)
    {:reply, {:ok, weight}, state}
  end

  defp select_if_weighted(input, weights) do
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
