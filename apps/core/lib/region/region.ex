defmodule Region.Region do
  use GenServer
  import Apex

  def start_link(name) do
    #
    # sample = MapSet.new([1..10])
    # children = [
    #   supervisor(Column.Supervisor, [sample])
    # ]
    #
    #   #create_columns(10, MapSet.new(1..100))
    #
    #
    # # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # # for other strategies and supported options
    # opts = [strategy: :one_for_one, name: Core.Supervisor]
    # Supervisor.start_link(children, opts)
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    #col_refs = create_columns(10, MapSet.new(1..100))
    {:ok, %{}}
  end

  # 5, MapSet.new([1,2,3,4,5,6,7,8,9,10]), []
  # [w,w,w,w,w]
  def create_columns(server, count, input_set) do
    # if count > 1 do
    #
    #   # Amount of inputs a column will map to
    #   subset_count = div(MapSet.size(input_set), count)
    #
    #   # Get sample based on subset count
    #   sample = MapSet.new(Enum.take_random input_set, subset_count)
    #
    #   # TODO (CHOKE): Make sure this is Tail Recursive so it is fast
    #   # Create a list and add recursive items to the end
    #   {:ok, pid} = Column.Supervisor.start_column(sample)
    #   [Process.monitor(pid)] ++ create_columns(count - 1, MapSet.difference(input_set, sample))
    # else
      #Column.Supervisor.start_column("Test")
      # Apex.ap pid
      # Process.monitor(pid)
    # end

    GenServer.call(server, {:create_columns, count, input_set})
  end

  def handle_call({:create_columns, count, set}, _from, refs) do
    {:ok, pid} = Column.Supervisor.start_column(MapSet.to_list(set))
    ref = Process.monitor(pid)
    refs = Map.put(refs, ref, set)
    {:reply, pid, {refs}}
  end
end
