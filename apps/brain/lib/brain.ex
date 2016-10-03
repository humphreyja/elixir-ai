defmodule Brain do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
     {:ok, %{}}
  end

  def atrophy(module, process, time) do
    GenServer.cast(__MODULE__, {:atrophy, module, process, time})
  end

  def handle_cast({:atrophy, module, process, time}, state) do
    run_atrophy(module, process, time)
    {:noreply, state}
  end

  defp run_atrophy(module, process, time) do
    spawn(__MODULE__, :handle_atrophy, [module, process, time, 1])
  end

  def handle_atrophy(module, process, time, count) do
    time_coef = round(time * 0.25)
    high_time = time + time_coef
    low_time = time - time_coef
    if (low_time <= 0) do
      low_time = 1
    end
    run_time = Enum.random(low_time..high_time)
    :timer.sleep(run_time)
    module.atrophy(process)

    Brain.handle_atrophy(module, process, time, count + 1)
  end

end
