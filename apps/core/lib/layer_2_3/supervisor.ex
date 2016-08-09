defmodule Layer23.Supervisor do
  use Supervisor

  @name Layer23.Supervisor

  def start_link(layer1) do
    Supervisor.start_link(__MODULE__, layer1, name: @name)
  end

  def init(layer1) do
    children = [
      worker(Layer23.Core, [layer1])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
