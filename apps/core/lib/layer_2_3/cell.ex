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
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @doc """
  Initializes the cell with a name
  """
  def init(:ok) do
    {:ok, %{state: :inactive}}
  end

  def handle_call({:input, input}, _from, state) do
    # TODO: (STEP 6) - Check for predictive state, check input, return if will fire
    {:reply, {:ok, self}, state}
  end
end
