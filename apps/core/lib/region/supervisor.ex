defmodule Region.Supervisor do
  use Supervisor

  @name Region.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_region do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(Region.Region, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
