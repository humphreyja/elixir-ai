defmodule Layer23.Cell do
  use GenServer

  @doc """
  Sends an input to the cell server
  """
  def send_input(server, input) do
    case GenServer.call(server, {:input, input}) do
      {:ok, node} ->
        node
      {:error, _} ->
        nil
    end
  end

  @doc """
  Starts the server with the given name
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  @doc """
  Initializes the cell with a name
  """
  def init(name) do
    {:ok, %{name: name}}
  end

  def handle_call({:input, input}, _from, state) do
    # TODO: (STEP 5) - Check if input matches cell state, return self if true
    {:reply, {:ok, self}, state}
  end
end
