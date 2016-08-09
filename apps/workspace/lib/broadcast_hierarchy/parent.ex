defmodule BroadcastHierarchy.Parent do
  use GenServer
  def broadcast(server, message) do
    GenServer.call(server, {:broadcast, message})
  end



  @doc """
  Adds a child process with the given name
  """
  def add_child(name) do
    {:ok, pid} = BroadcastHierarchy.Child.start_link(name)
    pid
  end

  @doc """
  Adds a list of child processes
  """
  def add_children(count) do
    if count > 1 do
      [add_child(count)] ++ add_children(count - 1)
    else
      [add_child(count)]
    end
  end

  @doc """
  Starts the server with a given child count
  """
  def start_link(child_count) do
    GenServer.start_link(__MODULE__, child_count, [])
  end

  @doc """
  Initializes the server by building a child list
  """
  def init(child_count) do
    children = add_children(child_count)
    {:ok, %{children: children}}
  end

  @doc """
  Broadcasts a message to all the servers children.  Then it listens
  for a short period of time for children that replied and returns only those children
  """
  def handle_call({:broadcast, message}, _from, state) do
    nodes = state[:children]
            |> Enum.map(fn (elem) -> quick_gather(elem, message) end)
            |> Enum.filter(fn (elem) -> (elem != nil) end)
    {:reply, nodes, state}
  end

  @doc """
  Broadcasts a message to a child, then waits for 100 milsecs to see if the child has replied
  """
  def quick_gather(child, message) do
    pid = Task.async(fn -> BroadcastHierarchy.Child.send_message(child, message) end)

    answer = case Task.yield(pid, 100) do
      {:ok, node} ->
        node
      nil ->
        nil
    end
    answer
  end
end
