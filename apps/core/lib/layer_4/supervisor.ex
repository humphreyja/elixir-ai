defmodule Layer4.Supervisor do
  use Supervisor

  @name Layer4.Supervisor

  def start_link(layer23) do
    Supervisor.start_link(__MODULE__, layer23, name: @name)
  end

  def init(layer23) do
    children = [
      worker(Layer4.Core, [layer23])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
