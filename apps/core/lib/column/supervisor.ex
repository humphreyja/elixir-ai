defmodule Column.Supervisor do
  use Supervisor

  @name Column.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_column(mapset) do
    Supervisor.start_child(@name, [mapset])
  end

  def init(:ok) do
    children = [
      worker(Column.Column, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
