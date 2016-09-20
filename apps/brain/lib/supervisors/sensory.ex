defmodule Supervisors.Sensory do
  use Supervisor

  def start_link(sense) do
    Supervisor.start_link(__MODULE__, sense, [])
  end

  def init(sense) do
    children = [
      worker(sense, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
