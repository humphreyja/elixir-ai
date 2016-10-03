defmodule Supervisors.Cortex.Cells.Inhibitory do
  use Supervisor

  @name Inhibitory.Cell.Cortex.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(Cortex.Cells.Inhibitory, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_inhibitory(name) do
    Supervisor.start_child(@name, [name])
  end
end
