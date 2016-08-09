defmodule BroadcastHierarchy.Child do
  use GenServer

  @doc """
  Sends a message to the child server
  """
  def send_message(server, message) do
    node = GenServer.call(server, {:message, message})
    node
  end

  @doc """
  Starts the server with the given name
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  @doc """
  Initializes the child with a name
  """
  def init(name) do
    {:ok, %{name: name}}
  end

  @doc """
  Mimics slow computation and will run at a random interval
  """
  def handle_call({:message, _message}, _from, state) do
    :timer.sleep(Enum.random([0, 0, 1000, 3000]))
    {:reply, self(), state}
  end
end
